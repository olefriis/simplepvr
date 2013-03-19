module SimplePvr
  #
  # Simple fake version of HDHomeRun class. Makes it possible to run integration tests.
  #
  class HDHomeRunFake
    def scan_for_channels; end
    def start_recording(tuner, frequency, programme_id, directory); end
    def stop_recording(tuner); end
  end
  
  #
  # Encapsulates all the HDHomeRun-specific functionality. Do not initialize HDHomeRun objects yourself,
  # but get the current instance through PvrInitializer.
  #
  class HDHomeRun
    attr_reader :device_id

    def initialize
      @device_id = discover
      @tuner_pids = [nil, nil]
      FileUtils.rm(tuner_control_file(0)) if File.exists?(tuner_control_file(0))
      FileUtils.rm(tuner_control_file(1)) if File.exists?(tuner_control_file(1))
    end

    def scan_for_channels
      file_name = 'channels.txt'
      scan_channels_with_tuner(file_name)
      Model::Channel.clear
      read_channels_file(file_name)
    end

    def start_recording(tuner, frequency, program_id, directory)
      set_tuner_to_frequency(tuner, frequency)
      set_tuner_to_program(tuner, program_id)
      @tuner_pids[tuner] = spawn_recorder_process(tuner, directory)
      PvrLogger.info("Process ID for recording on tuner #{tuner}: #{@tuner_pids[tuner]}")
    end

    def stop_recording(tuner)
      pid = @tuner_pids[tuner]
      PvrLogger.info("Stopping process #{pid} for tuner #{tuner}")
      send_control_c_to_process(tuner, pid)
      reset_tuner_frequency(tuner)
      @tuner_pids[tuner] = nil
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

      File.open(file_name, 'r:UTF-8') do |file|
        file.each_line do |line|
          if line =~ /^SCANNING: (\d*) .*$/
            channel_frequency = $1.to_i
          elsif line =~ /^PROGRAM (\d*): \d* (.*)$/
            channel_id = $1.to_i
            channel_name = $2.strip
            Model::Channel.add(channel_name, channel_frequency, channel_id)
          end
        end
      end
    end

    def set_tuner_to_frequency(tuner, frequency)
      system "hdhomerun_config #{@device_id} set /tuner#{tuner}/channel auto:#{frequency}"
    end

    def set_tuner_to_program(tuner, program_id)
      system "hdhomerun_config #{@device_id} set /tuner#{tuner}/program #{program_id}"
    end

    def spawn_recorder_process(tuner, directory)
      FileUtils.touch(tuner_control_file(tuner))
      spawn File.dirname(__FILE__) + "/hdhomerun_save.sh #{@device_id} #{tuner} \"#{directory}/stream.ts\" \"#{directory}/hdhomerun_save.log\" \"#{tuner_control_file(tuner)}\""
    end
  
    def reset_tuner_frequency(tuner)
      system "hdhomerun_config #{@device_id} set /tuner#{tuner}/channel none"
    end

    def send_control_c_to_process(tuner, pid)
      FileUtils.rm(tuner_control_file(tuner))
      Process.wait(pid)
    end
  
    def tuner_control_file(tuner)
      "tuner#{tuner}.lock"
    end
  end
end
