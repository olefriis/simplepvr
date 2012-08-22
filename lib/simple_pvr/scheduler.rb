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
    attr_reader :upcoming_recordings
    
    def initialize
      @upcoming_recordings, @current_recordings, @recorders = [], [nil, nil], {}
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
        @upcoming_recordings = recordings.sort_by {|r| r.start_time }.find_all {|r| !r.expired? }
        PvrLogger.info("Scheduling upcoming recordings: #{@upcoming_recordings}")

        @scheduled_programmes = programme_ids_from(@upcoming_recordings)
        stop_current_recordings_not_relevant_anymore
        @upcoming_recordings = remove_current_recordings(@upcoming_recordings)
      end
    end
    
    def is_scheduled?(programme)
      @scheduled_programmes[programme.id] != nil
    end
    
    def status_text
      @mutex.synchronize do
        return 'Idle' unless is_recording?

        status_texts = active_recordings.map {|recording| "'#{recording.show_name}' on channel '#{recording.channel.name}'"}
        'Recording ' + status_texts.join(', ')
      end
    end

    def process
      check_expiration_of_current_recordings
      check_start_of_coming_recordings
    end
    
    private
    def is_recording?
      !active_recordings.empty?
    end
    
    def active_recordings
      @current_recordings.find_all {|recording| recording }
    end
    
    def programme_ids_from(recordings)
      result = {}
      recordings.each do |recording|
        result[recording.programme.id] = true if recording.programme
      end
      result
    end
    
    def remove_current_recordings(recordings)
      recordings.find_all {|recording| !@current_recordings.include?(recording) }
    end
    
    def stop_current_recordings_not_relevant_anymore
      @current_recordings.each do |recording|
        stop_recording(recording) if recording && !@upcoming_recordings.include?(recording)
      end
    end
    
    def check_expiration_of_current_recordings
      @current_recordings.each do |recording|
        stop_recording(recording) if recording && recording.expired?
      end
    end
    
    def check_start_of_coming_recordings
      while should_start_next_recording
        start_next_recording
      end
    end
    
    def should_start_next_recording
      next_recording = @upcoming_recordings[0]
      next_recording && next_recording.start_time <= Time.now
    end
    
    def stop_recording(recording)
      @recorders[recording].stop!
      @recorders[recording] = nil
      @current_recordings[@current_recordings.find_index(recording)] = nil
    end
    
    def start_next_recording
      next_recording = @upcoming_recordings.delete_at(0)
      available_slot = @current_recordings.find_index(nil)
      if available_slot
        recorder = Recorder.new(available_slot, next_recording)
        @current_recordings[available_slot] = next_recording
        @recorders[next_recording] = recorder
        recorder.start!
      end
    end
  end
end