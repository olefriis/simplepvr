require File.dirname(__FILE__) + '/lib/simple_pvr'
require 'sinatra'

SimplePvr::PvrInitializer.setup
dao = SimplePvr::PvrInitializer.dao
scheduler = SimplePvr::PvrInitializer.scheduler
SimplePvr::DatabaseScheduleReader.read

get '/' do
  schedules = dao.schedules
  upcoming_recordings = scheduler.coming_recordings
  erb :index, locals: { schedules: schedules, upcoming_recordings: upcoming_recordings }
end

get '/schedules/new' do
  erb :'schedules/new', locals: { channels: dao.channels }
end

post '/schedules/create' do
  title, channel_id, channel = params[:title], params[:channel_id].to_i, nil
  channel = SimplePvr::Channel.get(channel_id) if channel_id > 0
  dao.add_schedule_specification(title: title, channel: channel)
  reload_schedules
end

post '/schedules/:id/delete' do
  schedule_id = params[:id]
  SimplePvr::Schedule.get(schedule_id).destroy
  reload_schedules
end

def reload_schedules
  SimplePvr::DatabaseScheduleReader.read
  redirect '/'
end