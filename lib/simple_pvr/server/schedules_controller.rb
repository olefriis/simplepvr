module SimplePvr
  module Server
    class SchedulesController < BaseController
      get '/' do
        Model::Schedule.all.map do |schedule|
          {
            id: schedule.id,
            title: schedule.title,
            channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil,
            start_time: schedule.start_time,
            is_exception: schedule.type == :exception
          }
        end.to_json
      end

      post '/' do
        parameters = JSON.parse(request.body.read)
        title, channel_id, channel = parameters['title'], parameters['channel_id'].to_i, nil
        channel = Model::Channel.get(channel_id) if channel_id > 0
        result = Model::Schedule.add_specification(title: title, channel: channel)
        reload_schedules
        result.to_json
      end

      delete '/:id' do |id|
        Model::Schedule.get(id).destroy
        reload_schedules
        ''
      end

      post '/reload' do
        reload_schedules
      end
    end
  end
end