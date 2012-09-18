require File.dirname(__FILE__) + '/model/programme'

module SimplePvr
  class RecordingPlanner
    def initialize
      @recordings = []
    end
    
    def specification(options)
      title, channel, start_time = options[:title], options[:channel], options[:start_time]
      if channel && start_time
        schedule_programmes(title, Model::Programme.on_channel_with_title_and_start_time(channel, title, start_time))
      elsif channel
        schedule_programmes(title, Model::Programme.on_channel_with_title(channel, title))
      else
        schedule_programmes(title, Model::Programme.with_title(title))
      end
    end
    
    def finish
      PvrInitializer.scheduler.recordings = @recordings
    end
    
    private
    def schedule_programmes(title, programmes)
      programmes.each do |programme|
        start_time = programme.start_time.advance(minutes: -2)
        duration = programme.duration + 7.minutes
        add_recording(title, programme.channel, start_time, duration, programme)
      end
    end
    
    def add_recording(title, channel, start_time, duration, programme=nil)
      @recordings << Recording.new(channel, title, start_time, duration, programme)
    end
  end
end
