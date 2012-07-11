class DeviceFinder
  def self.find
    IO.popen('hdhomerun_config discover') do |pipe|
      output = pipe.read
      return $1 if output =~ /^hdhomerun device (.*) found at .*$/
      
      raise Exception, "No device found: #{output}"
    end
  end
end