require File.dirname(__FILE__) + '/lib/simple_pvr'
require 'sinatra'

include ERB::Util

SimplePvr::PvrInitializer.setup
SimplePvr::DatabaseScheduleReader.read
recording_manager = SimplePvr::RecordingManager.new

Time::DATE_FORMATS[:programme_date] = '%F'
Time::DATE_FORMATS[:day] = '%a, %d %b'

http_username, http_password = ENV['username'], ENV['password']
if http_username && http_password
  SimplePvr::PvrLogger.info('Securing server with Basic HTTP Authentication')
  use Rack::Auth::Basic, 'Restricted Area' do |username, password|
    [username, password] == [http_username, http_password]
  end
else
  SimplePvr::PvrLogger.info('Beware: Unsecured server. Do not expose to the rest of the world!')
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/schedules/?' do
  SimplePvr::Model::Schedule.all.map do |schedule|
    {
      id: schedule.id,
      title: schedule.title,
      channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil
    }
  end.to_json
end

post '/schedules/?' do
  parameters = JSON.parse(request.body.read)
  title, channel_id, channel = parameters['title'], parameters['channel_id'].to_i, nil
  puts "Title: #{title}, channel: #{channel_id}"
  channel = SimplePvr::Model::Channel.get(channel_id) if channel_id > 0
  result = SimplePvr::Model::Schedule.add_specification(title: title, channel: channel)
  reload_schedules
  result.to_json
end

delete '/schedules/:id' do |id|
  SimplePvr::Model::Schedule.get(id).destroy
  reload_schedules
  ''
end

get '/upcoming_recordings/?' do
  SimplePvr::PvrInitializer.scheduler.upcoming_recordings.map do |recording|
    {
      programme_id: recording.programme.id,
      show_name: recording.show_name,
      start_time: recording.start_time,
      channel: { id: recording.channel.id, name: recording.channel.name },
      subtitle: recording.programme ? recording.programme.subtitle : nil,
      description: recording.programme ? recording.programme.description : nil
    }
  end.to_json
end

post '/schedules/reload' do
  reload_schedules
end

get '/channels/?' do
  SimplePvr::Model::Channel.sorted_by_name.map do |channel|
    {
      id: channel.id,
      name: channel.name,
      hidden: channel.hidden
    }
  end.to_json
end

get '/channels/:channel_id/programme_listings/:date/?' do |channel_id, date_string|
  if date_string == 'today'
    now = Time.now
    this_date = Time.local(now.year, now.month, now.day)
  else
    this_date = Time.parse(date_string)
  end
  previous_date = this_date.advance(days: -7)
  next_date = this_date.advance(days: 7)
  channel = SimplePvr::Model::Channel.get(channel_id)

  days = (0..6).map do |date_advanced|
    from_date = this_date.advance(days: date_advanced)
    to_date = this_date.advance(days: date_advanced + 1)
    programmes = SimplePvr::Model::Programme.all(channel: channel, start_time: (from_date..to_date), order: :start_time)

    {
      date: from_date.to_s(:programme_date),
      programmes: programmes.map do |programme|
        {
          id: programme.id,
          start_time: programme.start_time,
          title: programme.title,
          scheduled: SimplePvr::PvrInitializer.scheduler.is_scheduled?(programme)
        }
      end
    }
  end
  
  {
    channel: { id: channel.id, name: channel.name },
    previous_date: previous_date.to_s(:programme_date),
    this_date: this_date.to_s(:programme_date),
    next_date: next_date.to_s(:programme_date),
    days: days
  }.to_json
end

get '/channels/:id' do |id|
  channel = SimplePvr::Model::Channel.get(id)
  {
    id: channel.id,
    name: channel.name,
    hidden: channel.hidden
  }.to_json
end

post '/channels/:id/hide' do |id|
  channel = SimplePvr::Model::Channel.get(id)
  channel.hidden = true
  channel.save
  {
    id: channel.id,
    name: channel.name,
    hidden: channel.hidden
  }.to_json
end

post '/channels/:id/show' do |id|
  channel = SimplePvr::Model::Channel.get(id)
  channel.hidden = false
  channel.save
  {
    id: channel.id,
    name: channel.name,
    hidden: channel.hidden
  }.to_json
end

get '/programmes/title_search' do
  SimplePvr::Model::Programme.titles_containing(params['query']).to_json
end

get '/programmes/search' do
  SimplePvr::Model::Programme.with_title_containing(params['query']).map {|programme| programme_hash(programme) }.to_json
end

get '/programmes/:id' do |id|
  programme = SimplePvr::Model::Programme.get(id)
  programme_hash(programme).to_json
end

post '/programmes/:id/record_on_any_channel' do |id|
  programme = SimplePvr::Model::Programme.get(id.to_i)
  SimplePvr::Model::Schedule.add_specification(title: programme.title)
  reload_schedules
  programme_hash(programme).to_json
end

post '/programmes/:id/record_on_this_channel' do |id|
  programme = SimplePvr::Model::Programme.get(id.to_i)
  SimplePvr::Model::Schedule.add_specification(title: programme.title, channel: programme.channel)
  reload_schedules
  programme_hash(programme).to_json
end

def programme_hash(programme)
  is_scheduled = SimplePvr::PvrInitializer.scheduler.is_scheduled?(programme)
  {
    id: programme.id,
    channel: { id: programme.channel.id, name: programme.channel.name },
    title: programme.title,
    subtitle: programme.subtitle,
    description: programme.description,
    start_time: programme.start_time,
    is_scheduled: is_scheduled
  }
end

get '/shows' do
  shows = recording_manager.shows
  shows.map do |show|
    {
      id: show,
      name: show
    }
  end.to_json
end

get '/shows/:id/?' do |id|
  {
    id: id,
    name: id
  }.to_json
end

delete '/shows/:id/?' do |id|
  recording_manager.delete_show(id)
  ''
end

get '/shows/:show_id/recordings/?' do |show_id|
  recordings = recording_manager.episodes_of(show_id)
  recordings.map do |recording|
    {
      id: recording.episode,
      show_id: show_id,
      episode: recording.episode,
      subtitle: recording.subtitle,
      description: recording.description,
      start_time: recording.start_time,
      channel_name: recording.channel
    }
  end.to_json
end

delete '/shows/:show_id/recordings/:episode' do |show_id, episode|
  recording_manager.delete_show_episode(show_id, episode)
  ''
end

get '/status' do
  {
    status_text: SimplePvr::PvrInitializer.scheduler.status_text
  }.to_json
end

def reload_schedules
  SimplePvr::DatabaseScheduleReader.read
end