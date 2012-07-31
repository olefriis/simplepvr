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
  end
end