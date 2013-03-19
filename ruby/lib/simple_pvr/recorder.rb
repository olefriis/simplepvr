require 'fileutils'
require File.dirname(__FILE__) + '/hdhomerun'
require File.dirname(__FILE__) + '/pvr_logger'

module SimplePvr
  class Recorder
    def initialize(tuner, recording)
      @tuner, @recording = tuner, recording
    end
  
    def start!
      @directory = PvrInitializer.recording_manager.create_directory_for_recording(@recording)
      PvrInitializer.hdhomerun.start_recording(@tuner, @recording.channel.frequency, @recording.channel.channel_id, @directory)
    
      PvrLogger.info "Started recording #{@recording.show_name} in #{@directory}"
    end
  
    def stop!
      PvrInitializer.hdhomerun.stop_recording(@tuner)
      Ffmpeg.create_thumbnail_for(@directory)
    
      PvrLogger.info "Stopped recording #{@recording.show_name}"
    end
  end
end