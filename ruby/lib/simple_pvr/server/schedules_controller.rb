module SimplePvr
  module Server
    class SchedulesController < BaseController
      # Must come before the "post '/:id'" below, or it won't get hit :-)
      post '/reload' do
        reload_schedules
      end

      get '/' do
        Model::Schedule.all.map {|schedule| schedule_map(schedule)}.to_json
      end

      post '/' do
        parameters = JSON.parse(request.body.read)
        title, channel_id, channel = parameters['title'], parameters['channel_id'].to_i, nil
        channel = Model::Channel.get(channel_id) if channel_id > 0
        result = Model::Schedule.add_specification(title: title, channel: channel)
        reload_schedules
        result.to_json
      end
      
      get '/:id' do |id|
        schedule_map(Model::Schedule.get(id)).to_json
      end
      
      post '/:id' do |id|
        parameters = JSON.parse(request.body.read)
        channel_id = parameters['channel'] != nil ? parameters['channel']['id'].to_i : 0
        schedule = Model::Schedule.get(id)
        schedule.title = parameters['title']
        schedule.channel = channel_id > 0 ? Model::Channel.get(channel_id) : nil

        schedule.custom_start_early_minutes = parameters['custom_start_early_minutes'].present? ? parameters['custom_start_early_minutes'].to_i : nil
        schedule.custom_end_late_minutes = parameters['custom_end_late_minutes'].present? ? parameters['custom_end_late_minutes'].to_i : nil

        schedule.filter_by_time_of_day = parameters['filter_by_time_of_day']
        schedule.from_time_of_day = parameters['from_time_of_day']
        schedule.to_time_of_day = parameters['to_time_of_day']

        schedule.filter_by_weekday = parameters['filter_by_weekday'] ? true : nil
        schedule.monday = parameters['monday']
        schedule.tuesday = parameters['tuesday']
        schedule.wednesday = parameters['wednesday']
        schedule.thursday = parameters['thursday']
        schedule.friday = parameters['friday']
        schedule.saturday = parameters['saturday']
        schedule.sunday = parameters['sunday']
        schedule.save!
        reload_schedules
        ''
      end

      delete '/:id' do |id|
        Model::Schedule.get(id).destroy
        reload_schedules
        ''
      end
      
      private
      def schedule_map(schedule)
        {
          id: schedule.id,
          title: schedule.title,
          channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil,
          start_time: schedule.start_time,
          is_exception: schedule.type == :exception,

          custom_start_early_minutes: schedule.custom_start_early_minutes,
          custom_end_late_minutes: schedule.custom_end_late_minutes,
          start_early_minutes: schedule.start_early_minutes,
          end_late_minutes: schedule.end_late_minutes,

          filter_by_time_of_day: schedule.filter_by_time_of_day,
          from_time_of_day: schedule.from_time_of_day,
          to_time_of_day: schedule.to_time_of_day,

          filter_by_weekday: schedule.filter_by_weekday,
          monday: schedule.monday,
          tuesday: schedule.tuesday,
          wednesday: schedule.wednesday,
          thursday: schedule.thursday,
          friday: schedule.friday,
          saturday: schedule.saturday,
          sunday: schedule.sunday
        }
      end
    end
  end
end