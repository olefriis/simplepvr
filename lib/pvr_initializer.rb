require File.dirname(__FILE__) + '/device_finder'

class PvrInitializer
  def self.setup
    unless File.exists?('channels.txt')
      device_id = DeviceFinder.find
      system "hdhomerun_config #{device_id} scan /tuner0 channels.txt"
    end
  end
end