require 'fileutils'
require File.dirname(__FILE__) + '/hd_home_run'
require File.dirname(__FILE__) + '/directory_creator'
require File.dirname(__FILE__) + '/pvr_logger'

class Recorder
  def initialize(show_name, frequency, program_id)
    @show_name, @frequency, @program_id = show_name, frequency, program_id
    
    @hd_home_run = HDHomeRun.new
  end
  
  def start!
    directory = DirectoryCreator.create_for_show(@show_name)
    @hd_home_run.start_recording(@frequency, @program_id, directory)
    
    PvrLogger.info "Started recording #{@show_name} in #{directory}"
  end
  
  def stop!
    @hd_home_run.stop_recording
    
    PvrLogger.info "Stopped recording #{@show_name}"
  end
end