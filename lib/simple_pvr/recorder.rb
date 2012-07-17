require 'fileutils'
require File.dirname(__FILE__) + '/hd_home_run'
require File.dirname(__FILE__) + '/pvr_logger'

module SimplePvr
  class Recorder
    def initialize(show_name, frequency, program_id)
      @show_name, @frequency, @program_id = show_name, frequency, program_id
    
      @hd_home_run = HDHomeRun.new
    end
  
    def start!
      directory = create_for_show(@show_name)
      @hd_home_run.start_recording(@frequency, @program_id, directory)
    
      PvrLogger.info "Started recording #{@show_name} in #{directory}"
    end
  
    def stop!
      @hd_home_run.stop_recording
    
      PvrLogger.info "Stopped recording #{@show_name}"
    end
  
    private
    def create_for_show(show_name)
      base_directory_for_show = "recordings/#{show_name}"
      new_sequence_number = Dir.exists?(base_directory_for_show) ? find_new_sequence_number_for(base_directory_for_show) : 1
      new_directory_name = "#{base_directory_for_show}/#{new_sequence_number}"
      FileUtils.makedirs(new_directory_name)
      new_directory_name
    end
  
    def find_new_sequence_number_for(base_directory)
      largest_current_sequence_number = Dir.new(base_directory).map {|dir_name| dir_name.to_i }.max
      1 + largest_current_sequence_number
    end
  end
end