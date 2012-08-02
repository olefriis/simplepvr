require File.dirname(__FILE__) + '/recorder'
require File.dirname(__FILE__) + '/pvr_logger'

module SimplePvr
  Recording = Struct.new(:channel, :show_name, :start_time, :duration, :programme)

  class Recording
    def expired?
      start_time.advance(seconds: duration) < Time.now
    end
    
    def inspect
      "'#{show_name}' from '#{channel.name}' at '#{start_time}'"
    end
  end

  class Scheduler
    attr_reader :coming_recordings
    
    def initialize
      @coming_recordings, @current_recording, @recorder = [], nil, nil
      @mutex = Mutex.new
    end

    def start
      @thread = Thread.new do
        while true
          @mutex.synchronize { process }
          sleep 1
        end
      end
    end
    
    def recordings=(recordings)
      @mutex.synchronize do
        @coming_recordings = recordings.sort_by {|r| r.start_time }.find_all {|r| !r.expired? }
        PvrLogger.info("Scheduling coming recordings: #{@coming_recordings}")

        @scheduled_programmes = {}
        @coming_recordings.each do |recording|
          @scheduled_programmes[recording.programme.id] = true if recording.programme
        end

        if @current_recording && @coming_recordings[0] != @current_recording
          stop_current_recording
        end
      end
    end
    
    def is_scheduled?(programme)
      @scheduled_programmes[programme.id]
    end
    
    def status_text
      @mutex.synchronize do
        if @current_recording
          "Recording '#{@current_recording.show_name}' on channel '#{@current_recording.channel.name}'"
        else
          'Idle'
        end
      end
    end

    def process
      if is_recording?
        check_expiration_of_current_recording
      else
        check_start_of_coming_recording
      end
    end
    
    private
    def is_recording?
      @recorder != nil
    end
    
    def check_expiration_of_current_recording
      if @current_recording.expired?
        stop_current_recording
      end
    end
    
    def stop_current_recording
      @recorder.stop! 
      @current_recording, @recorder = nil, nil
    end
    
    def check_start_of_coming_recording
      coming_recording = @coming_recordings[0]
      return unless coming_recording
      
      if coming_recording.start_time <= Time.now
        start_new_recording
      end
    end
    
    def start_new_recording
      @current_recording = @coming_recordings.delete_at(0)
      @recorder = Recorder.new(0, @current_recording)
      @recorder.start!
    end
  end
end