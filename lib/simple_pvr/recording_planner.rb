module SimplePvr
  class RecordingPlanner
    def initialize
      @recordings = []
      @dao = PvrInitializer.dao
    end
    
    def simple(title, channel, start_time, duration)
      add_recording(title, channel, start_time, duration)
    end
    
    def specification(options)
      title, channel = options[:title], options[:channel]
      if channel
        schedule_programmes(title, @dao.programmes_on_channel_with_title(channel, title))
      else
        schedule_programmes(title, @dao.programmes_with_title(title))
      end
    end
    
    def finish
      PvrInitializer.scheduler.recordings = @recordings
    end
    
    private
    def schedule_programmes(title, programmes)
      programmes.each do |programme|
        start_time = programme.start_time.to_time - 2.minutes
        duration = programme.duration + 7.minutes
        add_recording(title, programme.channel, start_time, duration)
      end
    end
    
    def add_recording(title, channel, start_time, duration)
      @recordings << Recording.new(channel, title, start_time, duration)
    end
  end
end
