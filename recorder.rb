require 'fileutils'

class Recorder
  def initialize(show_name, device_id, frequency, program_id)
    @show_name, @device_id, @frequency, @program_id = show_name, device_id, frequency, program_id
  end
  
  def start!
    directory = "recordings/#{@show_name}"
    create_fresh_directory directory

    system "hdhomerun_config #{@device_id} set /tuner0/channel auto:#{@frequency}"
    system "hdhomerun_config #{@device_id} set /tuner0/program #{@program_id}"
    @pid = spawn "hdhomerun_config #{@device_id} save /tuner0 #{directory}/stream.ts", [:out, :err]=>["#{directory}/hdhomerun_save.log", "w"]
    
    puts "Started recording #{@show_name}"
  end
  
  def stop!
    Process.kill('INT', @pid)
    
    puts "Stopped recording #{@show_name}"
  end
  
  private
  def create_fresh_directory(directory_name)
    if Dir.exists?(directory_name)
      FileUtils.remove_dir directory_name
    end
    FileUtils.makedirs directory_name
  end
end