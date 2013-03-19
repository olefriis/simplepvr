module SimplePvr
  class RecordingPlanner
    def self.reload
      Model::Schedule.cleanup

      planner = self.new
      planner.read
    end
    
    def initialize
      @recordings = []
    end

    def read
      schedules = Model::Schedule.all
      specifications = schedules.find_all {|s| s.type == :specification }
      exceptions = schedules.find_all {|s| s.type == :exception }
      
      specifications.each do |specification|
        programmes = programmes_matching(specification)
        programmes_with_exceptions_removed = programmes.find_all {|programme| !matches_exception(programme, exceptions) }
        programmes_filtered_by_weekdays = programmes_with_exceptions_removed.find_all {|programme| on_allowed_weekday(programme, specification) }
        programmes_filtered_by_time_of_day = programmes_filtered_by_weekdays.find_all {|programme| at_allowed_time_of_day(programme, specification) }

        add_programmes(specification, programmes_filtered_by_time_of_day)
      end

      PvrInitializer.scheduler.recordings = @recordings
    end
    
    private
    def programmes_matching(specification)
        if specification.channel && specification.start_time
          Model::Programme.on_channel_with_title_and_start_time(specification.channel, specification.title, specification.start_time)
        elsif specification.channel
          Model::Programme.on_channel_with_title(specification.channel, specification.title)
        else
          Model::Programme.with_title(specification.title)
        end
    end

    def matches_exception(programme, exceptions)
      exceptions.any? do |exception|
        programme.title == exception.title &&
        programme.channel == exception.channel &&
        programme.start_time == exception.start_time
      end
    end
    
    def on_allowed_weekday(programme, specification)
      return true unless specification.filter_by_weekday
      
      date = programme.start_time
      case true
      when date.monday? then specification.monday
      when date.tuesday? then specification.tuesday
      when date.wednesday? then specification.wednesday
      when date.thursday? then specification.thursday
      when date.friday? then specification.friday
      when date.saturday? then specification.saturday
      when date.sunday? then specification.sunday
      else false
      end
    end

    def at_allowed_time_of_day(programme, specification)
      return true unless specification.filter_by_time_of_day

      # When comparing times of day below, we convert all timestamps into an integer so that we can easily compare them.
      # We do this by converting e.g. "10:35" to the integer 1035.
      programme_pseudo_start_time = pseudo_time_of_day_from_datetime(programme.start_time)

      if specification.from_time_of_day && specification.to_time_of_day
        pseudo_from_time = pseudo_time_of_day_from_string(specification.from_time_of_day)
        pseudo_to_time = pseudo_time_of_day_from_string(specification.to_time_of_day)
        if pseudo_from_time < pseudo_to_time
          # Both times of day are at the same day
          programme_pseudo_start_time >= pseudo_time_of_day_from_string(specification.from_time_of_day) &&
          programme_pseudo_start_time <= pseudo_time_of_day_from_string(specification.to_time_of_day)
        else
          # Stretching across midnight
          programme_pseudo_start_time >= pseudo_time_of_day_from_string(specification.from_time_of_day) ||
          programme_pseudo_start_time <= pseudo_time_of_day_from_string(specification.to_time_of_day)
        end
      elsif specification.from_time_of_day
        programme_pseudo_start_time >= pseudo_time_of_day_from_string(specification.from_time_of_day)
      elsif specification.to_time_of_day
        programme_pseudo_start_time <= pseudo_time_of_day_from_string(specification.to_time_of_day)
      else
        true
      end
    end
    
    def add_programmes(schedule, programmes)
      programmes.each do |programme|
        start_time = programme.start_time.advance(minutes: -schedule.start_early_minutes)
        duration = programme.duration + (schedule.start_early_minutes + schedule.end_late_minutes).minutes
        add_recording(schedule.title, programme.channel, start_time, duration, programme)
      end
    end
    
    def add_recording(title, channel, start_time, duration, programme=nil)
      @recordings << SimplePvr::Model::Recording.new(channel, title, start_time, duration, programme)
    end

    # Given a time of day as string, e.g. "10:35", returns an integer which can be used to compare with other
    # times of day, e.g. "1035"
    def pseudo_time_of_day_from_string(s)
      components = s.split(':')
      components[0].to_i * 100 + components[1].to_i
    end

    # Given a datetime, representing e.g. "10:35", returns an integer which can be used to compare with other
    # times of day, e.g. "1035"
    def pseudo_time_of_day_from_datetime(datetime)
      datetime.hour * 100 + datetime.min
    end
  end
end
