require File.dirname(__FILE__) + '/lib/simple_pvr'
require 'sinatra'

SimplePvr::PvrInitializer.setup
scheduler = SimplePvr::PvrInitializer.scheduler
SimplePvr::DatabaseScheduleReader.read

get '/' do
  schedules = SimplePvr::Model::Schedule.all
  upcoming_recordings = scheduler.coming_recordings
  channels = SimplePvr::Model::Channel.sorted_by_name
  erb :index, locals: { schedules: schedules, upcoming_recordings: upcoming_recordings, channels: channels }
end

post '/schedules/reload' do
  reload_schedules
end

get '/schedules/new' do
  channels = SimplePvr::Model::Channel.sorted_by_name
  erb :'schedules/new', locals: { channels: channels }
end

post '/schedules/create' do
  title, channel_id, channel = params[:title], params[:channel_id].to_i, nil
  channel = SimplePvr::Model::Channel.get(channel_id) if channel_id > 0
  SimplePvr::Model::Schedule.add_specification(title: title, channel: channel)
  reload_schedules
end

post '/schedules/:id/delete' do
  schedule_id = params[:id]
  SimplePvr::Model::Schedule.get(schedule_id).destroy
  reload_schedules
end

get '/channels/:id' do
  now = Time.now
  date = Time.local(now.year, now.month, now.day)
  channel = SimplePvr::Model::Channel.get(params[:id])
  show_programmes_for_date(channel, date)
end

get '/channels/:id/for_date/:date' do
  date = Time.parse(params[:date])
  channel = SimplePvr::Model::Channel.get(params[:id])
  show_programmes_for_date(channel, date)
end

get '/programmes/:id' do
  programme = SimplePvr::Model::Programme.get(params[:id])
  erb :'programmes/show', locals: { programme: programme }
end

post '/programmes/:id/record_on_any_channel' do
  programme = SimplePvr::Model::Programme.get(params[:id].to_i)
  SimplePvr::Model::Schedule.add_specification(title: programme.title)
  reload_schedules
end

post '/programmes/:id/record_on_this_channel' do
  programme = SimplePvr::Model::Programme.get(params[:id].to_i)
  SimplePvr::Model::Schedule.add_specification(title: programme.title, channel: programme.channel)
  reload_schedules
end

def show_programmes_for_date(channel, date)
  yesterday_time = date.yesterday
  tomorrow_time = date.tomorrow
  yesterday = "#{yesterday_time.year}-#{yesterday_time.month}-#{yesterday_time.day}"
  tomorrow = "#{tomorrow_time.year}-#{tomorrow_time.month}-#{tomorrow_time.day}"
  programmes = SimplePvr::Model::Programme.all(channel: channel, start_date_time: (date..tomorrow_time), order: :start_date_time)
  erb :'channels/show', locals: { today: date, yesterday: yesterday, tomorrow: tomorrow, channel: channel, programmes: programmes }
end

def reload_schedules
  SimplePvr::DatabaseScheduleReader.read
  redirect '/'
end