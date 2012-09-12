import sqlite3

from flask import Flask, request, session, g, redirect, url_for, abort, render_template, flash

DATABASE = '../database.sqlite'
TEMPLATES = '../public'
DEBUG = True
SECRET_KEY = 'development key'
USERNAME = 'admin'
PASSWORD = 'default'

app = Flask(__name__)
app.config.from_object(__name__)

def connect_db():
    return sqlite3.connect(app.config['DATABASE'])

@app.before_request
def before_request():
    """Make sure we are connected to the database each request."""
    g.db = connect_db()


@app.teardown_request
def teardown_request(exception):
    """Closes the database again at the end of the request."""
    if hasattr(g, 'db'):
        g.db.close()

@app.route('/')
def show_entries():
    index = app.config['TEMPLATES'] + '/index.html'
    cur = g.db.execute('select name, frequency from channels order by id desc')
    #return render_template(index)
    return render_template('index.html')
    #//send_file File.join(settings.public_folder, 'index.html')

@app.route('/schedules/?', methods=['GET'])
def show_schedules():
#SimplePvr::Model::Schedule.all.map do |schedule|
#    {
#    id: schedule.id,
#    title: schedule.title,
#    channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil
#}
#end.to_json
#end
    return "TODO - show_schedules"

@app.route('/schedules/?', methods=['POST'])
def add_schedule():
#SimplePvr::Model::Schedule.all.map do |schedule|
#    {
#    id: schedule.id,
#    title: schedule.title,
#    channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil
#}
#end.to_json
#end
    return "TODO - add_schedule"

@app.route('/schedules/<id>', methods=['DELETE'])
def delete_schedule(id=0):
#SimplePvr::Model::Schedule.all.map do |schedule|
#    {
#    id: schedule.id,
#    title: schedule.title,
#    channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil
#}
#end.to_json
#end
#     return render_template('index.html', id=id)
    return "TODO - delete_schedule"

@app.route('/upcoming_recordings/?', methods=['GET'])
def upcoming_recordings():
    return "TODO - upcoming recordings"

@app.route('/schedules/reload', methods=['POST'])
def reload_schedules():
    return "TODO - reload_schedules"

@app.route('/channels/?', methods=['GET'])
def get_channels():
    return "TODO - get_channels"

@app.route('/channels/<channel_id>/programme_listings/<date_string>/?', methods=['GET'])
def get_programmes():
    return "TODO - get_programmes"

@app.route('/channels/<id>', methods=['GET'])
def get_channel():
    return "TODO - get_channel"

@app.route('/channels/<id>/hide', methods=['POST'])
def hide_channel():
    return "TODO - hide_channel"

@app.route('/channels/<id>/show', methods=['POST'])
def show_channel():
    return "TODO - show_channel"

@app.route('/programmes/<id>', methods=['GET'])
def get_program():
    return "TODO - get_program"

@app.route('/programmes/<id>/record_on_any_channel', methods=['POST'])
def record_on_any_channel():
    return "TODO - record_on_any_channel"

@app.route('/programmes/<id>/record_on_this_channel', methods=['POST'])
def record_on_this_channel():
    return "TODO - record_on_this_channel"

def programme_json(programme=None, methods=['GET']):
    return "TODO - programme_json"


@app.route('/shows', methods=['GET'])
def shows():
    return "TODO: shows"


@app.route('/shows/<id>/?', methods=['GET'])
def delete_show():
    return "TODO: shows and id - delete shows"


@app.route('/shows/<show_id>/recordings/?')
def show_details():
    return "TODO - show_details recordning "

@app.route('/shows/<show_id>/recordings/<episode>', methods=['DELETE'])
def delete_show_episode():
    return "TODO - delete"


@app.route('/status', methods=['GET'])
def status_test():
    return "TODO - status_text"

def reload_schedules():
#    SimplePvr::DatabaseScheduleReader.read
#end
    return "TODO - reload_schedules"

if __name__ == '__main__':
    app.run()

