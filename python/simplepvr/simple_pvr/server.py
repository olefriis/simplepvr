# -*- coding: <utf-8> -*-

import os
import sqlite3
from datetime import datetime, timedelta
from dateutil.parser import parse
from dateutil.tz import tzlocal

from .pvr_logger import logger
from .config import config_dir, getSimplePvrOption

basedir = os.path.abspath(os.path.dirname(__file__))

## Upper case constants used by from_object - will be put in app.config map
#DATABASE = 'simplepvr.sqlite'
#TEMPLATES = 'public/templates'
SECRET_KEY = 'development key'
USERNAME = 'admin'
PASSWORD = 'default'

DEBUG = True

from contextlib import closing
from flask import Flask, request, json, jsonify, session, g, redirect, url_for, abort, render_template, flash, send_file, send_from_directory, after_this_request, make_response, Response
from flask.ext.sqlalchemy import SQLAlchemy
from sqlalchemy import or_, and_, desc

app = Flask(__name__, static_folder= os.path.join(basedir, '../public/static'), template_folder= os.path.join(basedir, '../public/templates') )

SQLALCHEMY_DATABASE_URI = getSimplePvrOption("sqlite_uri", "file::memory:")
simplepvr_sqlite_path = getSimplePvrOption("sqlite_database")

app.config.from_object(__name__) # Set the Flask config defaults from the uppercase vars in this file
app.config.from_envvar(variable_name="CONF", silent=True) ## Override the defaults by specifying the path to a file in the CONF environment variable


db = SQLAlchemy(app)

print "Database URI: ", app.config['SQLALCHEMY_DATABASE_URI']

def connect_db():
    return sqlite3.connect(simplepvr_sqlite_path)

def init_db():
    """Creates the database tables."""
    with closing(connect_db()) as db:
        #with app.open_resource('schema.sql') as f:
        #    db.cursor().executescript(f.read())
        db.commit()

@app.before_request
def before_request():
    """Make sure we are connected to the database each request."""
    g.db = connect_db()


@app.teardown_request
def teardown_request( exception):
    """Closes the database again at the end of the request."""
    if hasattr(g, 'db'):
        g.db.close()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/favicon.ico')
def favicon():
    return url_for('static', filename='favicon.ico')

@app.route('/api/schedules', methods=['GET'])
def show_schedules():
    from .master_import import Schedule

    clauses = [Schedule.stop_time == None, Schedule.stop_time >= datetime.now()]

    schedules = Schedule.query.filter(or_(*clauses)).all()
    if schedules is None or len(schedules) == 0:
        logger().info("No schedules in database")
        return json.dumps([])
    return json.dumps([ schedule.serialize for schedule in schedules])


@app.route('/api/schedules', methods=['POST'])
def add_schedule():
    from .master_import import Schedule, Channel
    parameters = request.json

    title = parameters['title']
    channel_id = int(parameters['channel_id'])
    if channel_id > 0:
        channel = Channel.query.get(channel_id)
    else:
        channel = None

    if channel is not None:
        result = Schedule(title=title, channel=channel).add(True)
    else:
        logger().info("Channel is None")
        result = Schedule.add_specification(title)

    reload_schedules()
    return Response(response=json.dumps(result),
                    status=200,
                    mimetype="application/json")

@app.route('/api/schedules/<int:sched_id>', methods=['DELETE'])
def delete_schedule(sched_id):
    from .master_import import Schedule
    from .pvr_initializer import scheduler

    schedule_to_delete = Schedule.query.get(sched_id)
    scheduler().delete_schedule_from_upcoming_recordings(schedule_to_delete)

    Schedule.query.filter(Schedule.id == sched_id).delete()

    db.session.flush()
    db.session.commit()

    reload_schedules()
    return Response(status=204)


@app.route('/api/upcoming_recordings', methods=['GET'])
def upcoming_recordings():
    from .pvr_initializer import scheduler

    reload_schedules()

    recordings = []
    upcoming_recordings = scheduler().get_upcoming_recordings()

    for recording in upcoming_recordings:
        subtitle = None
        description = None
        if recording.programme is not None:
            subtitle = recording.programme.subtitle
            description = recording.programme.description

        recordings.append({
            'programme_id': recording.programme.id,
            'show_name': recording.show_name,
            'start_time': recording.start_time.replace(tzinfo=tzlocal()).isoformat(),
            'stop_time': recording.stop_time.replace(tzinfo=tzlocal()).isoformat(),
            'channel': { 'id': recording.channel.id, 'name': recording.channel.name, 'icon_url': recording.channel.icon_url },
            'subtitle': subtitle,
            'description': description,
            'is_conflicting': scheduler().is_conflicting(recording.programme)

        })

    return json.dumps(sorted(recordings, key=lambda rec: rec["start_time"]))

@app.route('/api/schedules/reload', methods=['GET','POST'])
def schedules_reload():
    reload_schedules()
    return ""

@app.route('/api/channels', methods=['GET'])
def get_channels():
    from .master_import import Channel

    ## TODO: Use this instead of stuff below ####
    list_channel_current_programmes = map(channel_with_current_programmes_hash, Channel.all_with_current_programmes())
    results = []
    for channel_current_programme in list_channel_current_programmes:
        channel_dict = channel_current_programme['channel'].serialize
        serialized_current_programme = None
        if channel_current_programme['current_programme'] is not None:
            serialized_current_programme = channel_current_programme['current_programme']  #.serialize

        serialized_programmes = []
        for programme in channel_current_programme['upcoming_programmes']:
            serialized_programmes.append(programme) ##.serialize

        programmes_dict = {'current_programme': serialized_current_programme,
                       'upcoming_programmes': serialized_programmes}
        results.append(dict(programmes_dict.items() + channel_dict.items())) ## channel items must be merged directly into the dict rather than exist as a 'channel' entry

    return json.dumps(results)

@app.route('/api/channels/<int:chan_id>', methods=['GET'])
def get_channel( chan_id):
    from .master_import import Channel
    from datetime import datetime

    current_programme = Channel.with_current_programmes(chan_id)
    current_programmes_hash = channel_with_current_programmes_hash(current_programme)
    channel_dict = current_programmes_hash['channel'].serialize
    programmes_dict = {'current_programme': current_programmes_hash['current_programme'],
                   'upcoming_programmes': current_programmes_hash['upcoming_programmes']}

    @after_this_request
    def set_content_type(response):
        response.headers['X-Generated-By'] = 'SimplePVR Python'
        response.mimetype = 'application/json'
        return response
    return json.dumps(dict(programmes_dict.items() + channel_dict.items()))


@app.route('/api/channels/<int:chan_id>/hide', methods=['POST'])
def hide_channel( chan_id):
    from .master_import import Channel

    channel = Channel.query.get(chan_id)
    channel.hidden = True
    channel.save()

    return json.dumps({'id' : channel.id, 'name' : channel.name, 'hidden' : channel.hidden})


@app.route('/api/channels/<int:chan_id>/show', methods=['POST'])
def show_channel( chan_id):
    from .master_import import Channel

    channel = Channel.query.get(chan_id)
    channel.hidden = False
    channel.save()

    return json.dumps({'id' : channel.id, 'name' : channel.name, 'hidden' : channel.hidden})



@app.route('/api/channels/<int:channel_id>/programme_listings/<date_string>', methods=['GET'])
def get_programmes( channel_id, date_string ):
    from .master_import import Channel, Programme
    from .pvr_initializer import scheduler

    #    get '/channels/:channel_id/programme_listings/:date' do |channel_id, date_string|
    if date_string == 'today':
        now = datetime.now()
        this_date = now #Time.local(now.year, now.month, now.day)
    else:
        this_date = parse(date_string)

    previous_date = this_date + timedelta(days = -7)
    next_date = this_date + timedelta(days = 7)
    channel = Channel.query.get(channel_id)
    days = []
    for date_advanced in range(7):
        from_date = this_date + timedelta(days = date_advanced)
        to_date = this_date + timedelta(days = date_advanced+1)

        programmes = Programme.query.filter(Programme.channel_id == channel_id, Programme.start_time.between(from_date, to_date)).order_by(Programme.start_time).all()

        myDict = dict({'date': from_date.isoformat()[:10]})# ISO 8601 date format YYYY-mm-dd
        dailyProgrammes = []
        for programme in programmes:

            dailyProgrammes.append(dict({
                'id': programme.id,
                'start_time': programme.start_time.strftime("%H:%M"),
                'title': programme.title,
                'scheduled': scheduler().is_scheduled(programme)
            }))
        myDict.update({'programmes': dailyProgrammes} )
        days.append(myDict)

    #    json.dumps({'channel': {'id': channel.id, 'name': channel.name}, 'days': days, 'next_date': next_date.isoformat()[:10], 'previous_date': previous_date.isoformat()[:10], 'this_date': this_date.isoformat()[:10]})
    return json.dumps({
        'channel': { 'id': channel.id, 'name': channel.name, 'icon_url': channel.icon_url },
        'previous_date': previous_date.isoformat()[:10], # ISO 8601 date format YYYY-mm-dd
        'this_date': this_date.isoformat()[:10], # ISO 8601 date format YYYY-mm-dd
        'next_date': next_date.isoformat()[:10], # ISO 8601 date format YYYY-mm-dd
        'days': days
    })


@app.route('/api/programmes/title_search', methods=['GET'])
def title_search():
    from .master_import import Programme

    query_arg = request.args.get('query')

    if query_arg:
        programmes = Programme.titles_containing(query_arg)
        return json.dumps([ programme.serialize for programme in programmes ])
    else:
        return json.dumps([])

@app.route('/api/programmes/search', methods=['GET'])
def search():
    from .master_import import Programme

    res = []
    query_arg = request.args.get('query')
    if query_arg:
        with_title_containing = Programme.with_title_containing(query_arg)
        for programme in with_title_containing:
            res.append(programme_hash(programme))
    return json.dumps(res)

@app.route('/api/programmes/<int:prog_id>', methods=['GET'])
def get_programme( prog_id):
    from .master_import import Programme

    programme = Programme.query.get(prog_id)
    return json.dumps(programme_hash(programme))

@app.route('/api/programmes/<int:prog_id>/record_on_any_channel', methods=['POST'])
def record_on_any_channel( prog_id):
    from .master_import import Programme, Schedule

    programme = Programme.query.get(prog_id)
    schedule_id = Schedule.add_specification(title=programme.title)
    reload_schedules()
    return json.dumps(programme_hash(programme))

@app.route('/api/programmes/<int:prog_id>/record_on_this_channel', methods=['POST'])
def record_on_channel( prog_id):
    from .master_import import Programme, Schedule

    programme = Programme.query.get(prog_id)
    Schedule.add_specification(title= programme.title, channel=programme.channel)
    reload_schedules()
    return json.dumps(programme_hash(programme))

@app.route('/api/programmes/<programme_id>/record_just_this_programme', methods=['POST'])
def record_single_programme(programme_id):
    from .master_import import Programme, Schedule
    programme = Programme.query.get(programme_id)
    if not programme:
        return Response(status=404)

    Schedule.add_specification(title= programme.title, start_time=programme.start_time, stop_time=programme.stop_time, channel=programme.channel)
    reload_schedules()
    return json.dumps(programme_hash(programme))

@app.route('/api/programmes/<int:prg_id>/exclude', methods=['POST'])
def exclude_programme(prg_id):
    from .master_import import Programme, Schedule
    programme = Programme.query.get(prg_id)
    if not programme:
        return Response(status=404)

    Schedule(title=programme.title, type='exception', channel=programme.channel, start_time=programme.start_time, stop_time=programme.stop_time).add(True)

    reload_schedules()
    return json.dumps(programme_hash(programme))


@app.route('/api/shows', methods=['GET'])
def get_shows():
    from .pvr_initializer import recording_manager
    result = []
    shows = recording_manager().shows()
    for show in shows:
        result.append({
            'id': show,
            'name': show
        })
    return json.dumps(result)

@app.route('/api/shows/<show_name>', methods=['GET'])
def get_show( show_name):
    from .pvr_initializer import recording_manager
    shows = recording_manager().shows()
    #idx = shows.index(show_name) if show_name in shows else -1
    if show_name in shows:
        idx = shows.index(show_name)
        return json.dumps({'id': shows[idx], 'name': shows[idx] })
    return Response(status=404)

@app.route('/api/shows/<show_name>', methods=['DELETE'])
def delete_show( show_name):
    if show_name is not None:
        from .pvr_initializer import recording_manager
        recording_manager().delete_show(show_name)
        return ''

@app.route('/api/shows/<show_name>/recordings', methods=['GET'])
def get_show_recordings( show_name):
    from .pvr_initializer import recording_manager
    result = []
    recordings = recording_manager().episodes_of(show_name)
    for recording in recordings:
        result.append(recording_hash(show_name, recording))
    if not result:
        return Response(status=404)
    return json.dumps(result)

@app.route('/api/shows/<show_name>/recordings/<int:recording_id>', methods=['GET'])
def get_recording_hash(show_name, recording_id):
    from .pvr_initializer import recording_manager
    recording = recording_manager()._metadata_for(show_name, recording_id)
    if recording:
        return json.dumps(recording_hash(show_name, recording))
    return Response(status=404)


@app.route('/api/shows/<show_name>/recordings/<episode>', methods=['DELETE'])
def delete_episode( show_name, episode):
    from .pvr_initializer import recording_manager
    recording_manager().delete_show_episode(show_name, episode)
    return ''

@app.route('/api/shows/<show_name>/recordings/<recording_id>/thumbnail.png', methods=['GET'])
def get_recording_thumbnail(show_name, recording_id):
    from .pvr_initializer import recording_manager
    path =  recording_manager()._directory_for_show_and_episode(show_name, recording_id)
    return send_from_directory(path, 'thumbnail.png')

@app.route('/api/shows/<show_name>/recordings/<recording_id>/stream.ts', methods=['GET'])
def get_recording_stream(show_name, recording_id):
    from .pvr_initializer import recording_manager
    path =  recording_manager()._directory_for_show_and_episode(show_name, recording_id)
    return send_from_directory(path, 'stream.ts')

@app.route('/api/shows/<show_name>/recordings/<recording_id>/stream.webm', methods=['GET'])
def get_recording_stream_webm(show_name, recording_id):
    from .pvr_initializer import recording_manager
    path =  recording_manager()._directory_for_show_and_episode(show_name, recording_id)
    return send_from_directory(path, 'stream.webm')

#@app.route('/api/shows/<show_name>/recordings/<recording_id>/transcode', methods=['POST'])
#def transcode(show_name, recording_id):



@app.route('/api/status', methods=['GET'])
def status( ):
    from .pvr_initializer import scheduler
    from .config import df_h
    import psutil

    return json.dumps({
        'status_text': scheduler().status_text(),
        'disk_free': df_h(),
        'sys_load': ''.join( str(x)+"% " for x in psutil.cpu_percent(interval=0.5, percpu=True))
    })


recording_planner = None
def reload_schedules():
    global recording_planner
    from .master_import import RecordingPlanner
    if recording_planner is None:
        recording_planner = RecordingPlanner()
    recording_planner.read()

def programme_hash(programme):
    from .pvr_initializer import scheduler
    from dateutil.tz import tzlocal
    is_scheduled = scheduler().is_scheduled(programme)

    iso_start_time = programme.start_time.replace(tzinfo=tzlocal())
    iso_stop_time = programme.stop_time.replace(tzinfo=tzlocal())

    return {
        'id': programme.id,
        'channel': { 'id': programme.channel.id, 'name': programme.channel.name },
        'title': programme.title,
        'subtitle': programme.subtitle,
        'description': programme.description,
        'start_time': iso_start_time.isoformat(),
        'stop_time': iso_stop_time.isoformat(),
        'is_scheduled': is_scheduled,
        'episode_num': programme.episode_num
    }

def recording_hash(show_id, recording):
    return {
        'id': recording.episode,
        'show_id': show_id,
        'episode': recording.episode,
        'subtitle': recording.subtitle,
        'description': recording.description,
        'start_time': recording.start_time.replace(tzinfo=tzlocal()).isoformat() if recording.start_time else None,
        'channel_name': recording.channel,
        'has_thumbnail': recording.has_thumbnail,
        'has_webm': recording.has_webm
    }

def channel_with_current_programmes_hash(channel_with_current_programmes):
    channel = channel_with_current_programmes['channel']
    current_programme = channel_with_current_programmes['current_programme']
    upcoming_programmes = channel_with_current_programmes['upcoming_programmes']

    upcoming_programmes_map = upcoming_programmes if upcoming_programmes is not None else []

    return {
        'id': channel.id,
        'name': channel.name,
        'hidden': channel.hidden,
        'icon_url': channel.icon_url,
        'channel': channel,
        'current_programme': current_programme,
        'upcoming_programmes': upcoming_programmes_map
    }

def programme_summaries_hash(programmes):
    return programmes.map(programme_summary_hash, programmes)

def programme_summary_hash(programme):
    from .pvr_initializer import scheduler
    return {
               'id': programme.id,
               'title': programme.title,
               'start_time': programme.start_time.replace(tzinfo=tzlocal()).isoformat(),
               'is_scheduled': scheduler().is_scheduled(programme),
           'is_conflicting': scheduler().is_conflicting(programme)
    }


def startServer():
    from .config import getSimplePvrInt
    app.run(host='0.0.0.0', port=getSimplePvrInt("http_port", 8000), debug=True)

if __name__ == "__main__":
    startServer()