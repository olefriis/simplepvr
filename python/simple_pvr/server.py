import os
import sqlite3
from datetime import datetime, timedelta
from dateutil.parser import parse

from .pvr_logger import logger

basedir = os.path.abspath(os.path.dirname(__file__))

DATABASE = 'database.sqlite'
#TEMPLATES = 'public/templates'
DEBUG = True
SECRET_KEY = 'development key'
USERNAME = 'admin'
PASSWORD = 'default'

SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, DATABASE)

from flask import Flask, request, json, jsonify, session, g, redirect, url_for, abort, render_template, flash
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__, static_folder= os.path.join(basedir, '../public/static'), template_folder= os.path.join(basedir, '../public/templates') )
app.config.from_object(__name__)
db = SQLAlchemy(app)

def connect_db():
    return sqlite3.connect(app.config['DATABASE'])

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
    schedules = Schedule.query.all()
    if schedules is None or len(schedules) == 0:
        logger().info("No schedules in database")
        return json.dumps([])
    return json.dumps([ schedule.serialize for schedule in schedules])
#    return jsonify(schedules=[ schedule.serialize for schedule in schedules])

#TODO - do the mapping below
#get '/schedules' do
#Model::Schedule.all.map do |schedule|
#    {
#    id: schedule.id,
#    title: schedule.title,
#    channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil
#}
#end.to_json
#end

@app.route('/api/schedules', methods=['POST'])
def add_schedule():
    from .master_import import Schedule, Channel
    parameters = request.json
    #parameters = JSON.parse(request.body.read)
    title = parameters['title']
    channel_id = int(parameters['channel_id'])

    channel = Channel.query.filter(Channel.id == channel_id).first()
    if channel is not None:
        result = Schedule.add_specification(title, channel)
    else:
        logger().info("Channel is None")
        result = Schedule.add_specification(title)

    reload_schedules()
    return jsonify(result)

@app.route('/api/schedules/<int:sched_id>', methods=['DELETE'])
def delete_schedule(sched_id):
    from .master_import import Schedule

    Schedule.query.filter(Schedule.id == sched_id).delete()

    db.session.flush()
    db.session.commit()

    reload_schedules
    return ''

@app.route('/api/upcoming_recordings', methods=['GET'])
def upcoming_recordings():
    from .pvr_initializer import scheduler

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
            'start_time': recording.start_time.isoformat(),
            'channel': { 'id': recording.channel.id, 'name': recording.channel.name },
            'subtitle': subtitle,
            'description': description

        })
    return json.dumps(recordings)

@app.route('/api/schedules/reload', methods=['POST'])
def schedules_reload():
    reload_schedules()
    return ""

@app.route('/api/channels', methods=['GET'])
def get_channels():
    from .master_import import Channel

    channels_sorted_by_name = Channel.sorted_by_name()

    if (channels_sorted_by_name is not None and len(channels_sorted_by_name)) > 0:
        logger().info("{} Channels found".format(len(channels_sorted_by_name)))
    else:
        logger().info("No channels found in database")
        channels_sorted_by_name = {}
    return json.dumps([channel.serialize  for channel in channels_sorted_by_name ])
#    return jsonify(channels=[channel.serialize  for channel in channels_sorted_by_name ] )

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

        programmes = Programme.query.filter(Programme.channel_id == channel_id, Programme.startTime.between(from_date, to_date)).order_by(Programme.startTime).all()

        myDict = dict({'date': from_date.isoformat()[:10]})
        dailyProgrammes = []
        for programme in programmes:

            dailyProgrammes.append(dict({
                'id': programme.id,
                'start_time': programme.startTime.strftime("%H:%M"),
                'title': programme.title,
                'scheduled': scheduler().is_scheduled(programme)
            }))
        myDict.update({'programmes': dailyProgrammes} )
        days.append(myDict) # ISO 8601 date format YYYY-mm-dd

#    json.dumps({'channel': {'id': channel.id, 'name': channel.name}, 'days': days, 'next_date': next_date.isoformat()[:10], 'previous_date': previous_date.isoformat()[:10], 'this_date': this_date.isoformat()[:10]})
    return jsonify({
        'channel': { 'id': channel.id, 'name': channel.name },
        'previous_date': previous_date.isoformat()[:10], # ISO 8601 date format YYYY-mm-dd
        'this_date': this_date.isoformat()[:10], # ISO 8601 date format YYYY-mm-dd
        'next_date': next_date.isoformat()[:10], # ISO 8601 date format YYYY-mm-dd
        'days': days
    })

@app.route('/api/channels/<int:chan_id>', methods=['GET'])
def get_channel( chan_id):
    from .master_import import Channel

    channel = Channel.query.get(chan_id)

    return jsonify(id = channel.id, name=channel.name, hidden=channel.hidden)


@app.route('/api/channels/<int:chan_id>/hide', methods=['POST'])
def hide_channel( chan_id):
    from .master_import import Channel

    channel = Channel.query.get(chan_id)
    channel.hidden = True
    db.session.flush()
    db.session.commit()
    return jsonify(id = channel.id, name=channel.name, hidden=channel.hidden)


@app.route('/api/channels/<int:chan_id>/show', methods=['POST'])
def show_channel( chan_id):
    from .master_import import Channel

    channel = Channel.get(chan_id)
    channel.hidden = False
    channel.save ## TODO commit?
    #    db.session.commit
    return jsonify(id = channel.id, name=channel.name, hidden=channel.hidden)

@app.route('/api/programmes/title_search', methods=['GET'])
def title_search():
    from .master_import import Programme
    programmes = Programme.titles_containing(request.args.get('query'))
    return jsonify(programmes=[ programme.serialize for programme in programmes ])

@app.route('/api/programmes/search', methods=['GET'])
def search():
    from .master_import import Programme

    res = []
    with_title_containing = Programme.with_title_containing(request.args.get('query'))
    for programme in with_title_containing:
        res.append(programme_hash(programme))
    return jsonify(res)

@app.route('/api/programmes/<int:prog_id>', methods=['GET'])
def get_programme( prog_id):
    from .master_import import Programme

    programme = Programme.query.get(prog_id)
    return jsonify(programme_hash(programme))

@app.route('/api/programmes/<int:prog_id>/record_on_any_channel', methods=['POST'])
def record_on_any_channel( prog_id):
    from .master_import import Programme, Schedule

    programme = Programme.query.get(prog_id)
    Schedule.add_specification(title=programme.title)
    reload_schedules
    return jsonify(programme_hash(programme))

@app.route('/api/programmes/<int:prog_id>/record_on_this_channel', methods=['POST'])
def record_on_channel( prog_id):
    from .master_import import Programme, Schedule

    programme = Programme.query.get(prog_id)
    Schedule.add_specification(title= programme.title, channel=programme.channel)
    reload_schedules
    return jsonify(programme_hash(programme))

def programme_hash( programme):
    from .pvr_initializer import scheduler
    is_scheduled = scheduler().is_scheduled(programme)
    return {
        'id': programme.id,
        'channel': { 'id': programme.channel.id, 'name': programme.channel.name },
        'title': programme.title,
        'subtitle': programme.subtitle,
        'description': programme.description,
        'start_time': programme.startTime.isoformat(),
        'is_scheduled': is_scheduled
    }

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
    return jsonify(result)

@app.route('/api/shows/<show_id>', methods=['GET'])
def get_show( show_id):
    from .pvr_initializer import recording_manager
    shows = recording_manager().shows()
    idx = shows.index(show_id)
    return jsonify({'id': show_id, 'name': shows[idx]})

@app.route('/api/shows/<int:show_id>', methods=['DELETE'])
def delete_show( show_id):
    if show_id is not None:
        from .pvr_initializer import recording_manager
        recording_manager().delete_show(show_id)
        return ''

@app.route('/api/shows/<show_id>/recordings', methods=['GET'])
def get_show_recordings( show_id):
    from .pvr_initializer import recording_manager
    result = []
    recordings = recording_manager().episodes_of(show_id)
    for recording in recordings:
        result.append({
            'id': recording.episode,
            'show_id': show_id,
            'episode': recording.episode,
            'subtitle': recording.subtitle,
            'description': recording.description,
            'start_time': recording.start_time,
            'channel_name': recording.channel
        })
    return jsonify(result)

@app.route('/api/shows/<show_id>/recordings/<episode>', methods=['DELETE'])
def delete_episode( show_id, episode):
    from .pvr_initializer import recording_manager
    recording_manager().delete_show_episode(show_id, episode)
    return ''

@app.route('/api/status', methods=['GET'])
def status( ):
    from .pvr_initializer import scheduler
    return jsonify({
        'status_text': scheduler().status_text()
    })


database_schedule_reader = None
def reload_schedules():
    from .master_import import DatabaseScheduleReader
    if database_schedule_reader is None:
        database_schedule_reader = DatabaseScheduleReader()
    database_schedule_reader.read()

def startServer():
    app.run(debug=True)

if __name__ == "__main__":
    startServer()