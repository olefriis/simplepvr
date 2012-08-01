module SimplePvr
  class RecordingManager
    def initialize(recordings_directory=nil)
      @recordings_directory = recordings_directory || Dir.pwd + '/recordings'
    end
    
    def shows
      Dir.new(@recordings_directory).entries - ['.', '..']
    end
    
    def delete_show(show_name)
      FileUtils.rm_rf(@recordings_directory + '/' + show_name)
    end
    
    def episodes_of(show_name)
      Dir.new(@recordings_directory + '/' + show_name).entries - ['.', '..']
    end
    
    def delete_show_episode(show_name, episode)
      FileUtils.rm_rf(@recordings_directory + '/' + show_name + '/' + episode)
    end

    def create_directory_for_recording(recording)
      base_directory_for_recording = @recordings_directory + '/' + recording.show_name
      new_sequence_number = Dir.exists?(base_directory_for_recording) ? find_new_sequence_number_for(base_directory_for_recording) : 1
      new_directory_name = "#{base_directory_for_recording}/#{new_sequence_number}"
      FileUtils.makedirs(new_directory_name)
      new_directory_name
    end

    private
    def find_new_sequence_number_for(base_directory)
      largest_current_sequence_number = Dir.new(base_directory).map {|dir_name| dir_name.to_i }.max
      1 + largest_current_sequence_number
    end
  end
end