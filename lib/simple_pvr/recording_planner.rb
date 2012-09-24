require File.dirname(__FILE__) + '/model/programme'

module SimplePvr
  class RecordingPlanner
    def self.read
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
        title = specification.title
        if specification.channel && specification.start_time
          programmes = Model::Programme.on_channel_with_title_and_start_time(specification.channel, specification.title, specification.start_time)
        elsif specification.channel
          programmes = Model::Programme.on_channel_with_title(specification.channel, specification.title)
        else
          programmes = Model::Programme.with_title(specification.title)
        end
        
        programmes_with_exceptions_removed = programmes.find_all {|programme| !matches_exception(programme, exceptions) }
        add_programmes(title, programmes_with_exceptions_removed)
      end

      PvrInitializer.scheduler.recordings = @recordings
    end
    
    private
    def matches_exception(programme, exceptions)
      exceptions.any? do |exception|
        programme.title == exception.title &&
        programme.channel == exception.channel &&
        programme.start_time == exception.start_time
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
