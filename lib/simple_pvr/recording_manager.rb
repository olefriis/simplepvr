require 'active_support/all'

module SimplePvr
  RecordingMetadata = Struct.new(:show_name, :episode, :channel, :subtitle, :description, :start_time, :duration)
  
  class RecordingManager
    def initialize(recordings_directory=nil)
      @recordings_directory = recordings_directory || Dir.pwd + '/recordings'
    end
    
    def shows
      Dir.new(@recordings_directory).entries - ['.', '..']
    end
    
    def delete_show(show_name)
      FileUtils.rm_rf(directory_for_show(show_name))
    end
    
    def episodes_of(show_name)
      episodes = Dir.new(directory_for_show(show_name)).entries - ['.', '..']
      result = episodes.map do |episode|
        metadata_for(show_name, episode)
      end
      puts "Result.length: #{result.length}"
      result
    end
    
    def delete_show_episode(show_name, episode)
      FileUtils.rm_rf(@recordings_directory + '/' + show_name + '/' + episode)
    end

    def create_directory_for_recording(recording)
      show_directory = directory_for_show(recording.show_name)
      ensure_directory_exists(show_directory)

      new_sequence_number = next_sequence_number_for(show_directory)
      recording_directory = "#{show_directory}/#{new_sequence_number}"
      ensure_directory_exists(recording_directory)

      create_metadata(recording_directory, recording)

      recording_directory
    end

    private
    def directory_for_show(show_name)
      @recordings_directory + '/' + show_name
    end
    
    def directory_for_show_and_episode(show_name, episode)
      @recordings_directory + '/' + show_name + '/' + episode
    end
    
    def ensure_directory_exists(directory)
      FileUtils.makedirs(directory) unless File.exists?(directory)
    end
    
    def next_sequence_number_for(base_directory)
      largest_current_sequence_number = Dir.new(base_directory).map {|dir_name| dir_name.to_i }.max
      1 + largest_current_sequence_number
    end
    
    def metadata_for(show_name, episode)
      metadata_file_name = directory_for_show_and_episode(show_name, episode) + '/metadata.yml'
      metadata = File.exists?(metadata_file_name) ? YAML.load_file(metadata_file_name) : {}
      
      RecordingMetadata.new(
        show_name,
        episode,
        metadata[:channel],
        metadata[:subtitle],
        metadata[:description],
        metadata[:start_time],
        metadata[:duration])
    end
    
    def create_metadata(directory, recording)
      metadata = {
        title: recording.show_name,
        channel: recording.channel.name,
        start_time: recording.start_time,
        duration: recording.duration
      }
      
      if recording.programme
        metadata.merge!({
          subtitle: recording.programme.subtitle,
          description: recording.programme.description
        })
      end
            
      File.open(directory + '/metadata.yml', 'w') {|f| f.write(metadata.to_yaml) }
    end
  end
end