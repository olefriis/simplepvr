require 'fileutils'
require File.dirname(__FILE__) + '/device_finder'
require File.dirname(__FILE__) + '/directory_creator'
require File.dirname(__FILE__) + '/pvr_logger'

class Recorder
  def initialize(show_name, frequency, program_id)
    @show_name, @frequency, @program_id = show_name, frequency, program_id
    
    @device_id = DeviceFinder.find
  end
  
  def start!
    directory = DirectoryCreator.create_for_show(@show_name)

    start_recording_in directory
    
    PvrLogger.info "Started recording #{@show_name} in #{directory}"
  end
  
  def stop!
    kill_recorder_process
    
    PvrLogger.info "Stopped recording #{@show_name}"
  end
  
  private
  def create_fresh_directory(directory_name)
    if Dir.exists?(directory_name)
      FileUtils.remove_dir directory_name
    end
    FileUtils.makedirs directory_name
  end
  
  def start_recording_in(directory)
    set_tuner_to_correct_frequency
    set_tuner_to_correct_program
    spawn_recorder_process_in directory
  end
  
  def set_tuner_to_correct_frequency
    system "hdhomerun_config #{@device_id} set /tuner0/channel auto:#{@frequency}"
  end
  
  def set_tuner_to_correct_program
    system "hdhomerun_config #{@device_id} set /tuner0/program #{@program_id}"
  end
  
  def spawn_recorder_process_in(directory)
    @pid = spawn "hdhomerun_config #{@device_id} save /tuner0 #{directory}/stream.ts", [:out, :err]=>["#{directory}/hdhomerun_save.log", "w"]
  end
  
  def kill_recorder_process
    Process.kill('INT', @pid)
  end
end