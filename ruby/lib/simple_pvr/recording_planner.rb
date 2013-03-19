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

        add_programmes(specification.title, programmes_filtered_by_weekdays)
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
    
    def add_programmes(title, programmes)
      programmes.each do |programme|
        start_time = programme.start_time.advance(minutes: -2)
        duration = programme.duration + 7.minutes
        add_recording(title, programme.channel, start_time, duration, programme)
      end
    end
    
    def add_recording(title, channel, start_time, duration, programme=nil)
      @recordings << SimplePvr::Model::Recording.new(channel, title, start_time, duration, programme)
    end
  end
end
