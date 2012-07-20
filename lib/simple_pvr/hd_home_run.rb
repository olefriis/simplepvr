module SimplePvr
  #
  # Encapsulates all the HDHomeRun-specific functionality. Do not initialize HDHomeRun objects yourself,
  # but get the current instance through PvrInitializer.
  #
  class HDHomeRun
    attr_reader :device_id
  
    def initialize(dao)
      @dao = dao
      @device_id = discover
    end
  
    def scan_for_channels
      file_name = 'channels.txt'
      scan_channels_with_tuner(file_name)
      @dao.clear_channels
      read_channels_file(file_name)
    end
  
    def start_recording(frequency, program_id, directory)
      set_tuner_to_frequency frequency
      set_tuner_to_program program_id
      @pid = spawn_recorder_process_in directory
    end
  
    def stop_recording
      send_control_c_to_process @pid
    end
  
    private
    def discover
      IO.popen('hdhomerun_config discover') do |pipe|
        output = pipe.read
        return $1 if output =~ /^hdhomerun device (.*) found at .*$/
      
        raise Exception, "No device found: #{output}"
      end
    end

    def scan_channels_with_tuner(file_name)
      system "hdhomerun_config #{@device_id} scan /tuner0 #{file_name}"
    end
    
    def read_channels_file(file_name)
      channel_frequency = nil

      File.open(file_name, 'r') do |file|
        file.each_line do |line|
          if line =~ /^SCANNING: (\d*) .*$/
            channel_frequency = $1.to_i
          elsif line =~ /^PROGRAM (\d*): \d* (.*)$/
            channel_id = $1.to_i
            channel_name = $2.strip
            @dao.add_channel(channel_name, channel_frequency, channel_id)
          end
        end
      end
    end

    def set_tuner_to_frequency(frequency)
      system "hdhomerun_config #{@device_id} set /tuner0/channel auto:#{frequency}"
    end
  
    def set_tuner_to_program(program_id)
      system "hdhomerun_config #{@device_id} set /tuner0/program #{program_id}"
    end
  
    def spawn_recorder_process_in(directory)
      spawn "hdhomerun_config #{@device_id} save /tuner0 \"#{directory}/stream.ts\"", [:out, :err]=>["#{directory}/hdhomerun_save.log", "w"]
    end
  
    def send_control_c_to_process(pid)
      Process.kill('INT', pid)
    end
  end
end