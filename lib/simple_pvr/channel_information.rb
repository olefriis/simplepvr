module SimplePvr
  class ChannelInformation
    def initialize(channels_file_name='channels.txt')
      @channel_information = {}
    
      frequency = nil
      File.open(channels_file_name, 'r') do |file|
        file.each_line do |line|
          if line =~ /^SCANNING: (\d*) .*$/
            frequency = $1.to_i
          elsif line =~ /^PROGRAM (\d*): \d* (.*)$/
            @channel_information[$2.strip] = [frequency, $1.to_i]
          end
        end
      end
    end
  
    def information_for(channel_name)
      information = @channel_information[channel_name]
      raise "Unknown channel: #{channel_name}" unless information
      information
    end
  end
end
