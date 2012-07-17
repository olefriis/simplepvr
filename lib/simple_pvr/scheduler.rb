require 'rufus/scheduler'
require File.dirname(__FILE__) + '/channel_information'
require File.dirname(__FILE__) + '/recorder'
require File.dirname(__FILE__) + '/pvr_logger'

module SimplePvr
  class Scheduler
    @@months = { 'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12}
  
    def initialize
      @scheduler = Rufus::Scheduler.start_new
      @channel_information = ChannelInformation.new
    end
  
    def add(show_name, options)
      channel, start_time, duration = options[:from], options[:at], options[:for]

      now = Time.now
      parsed_start_time = parse_time(start_time)

      if parsed_start_time + duration <  now
        PvrLogger.info("Skipping recording of #{show_name}, since #{start_time} is in the past")
        return
      elsif parsed_start_time < now
        PvrLogger.info("Show #{show_name} is in progress - adjusting duration")
        duration -= (now - parsed_start_time)
      else
        PvrLogger.info("Scheduling #{show_name} for #{parsed_start_time}")
      end

      frequency, id = @channel_information.information_for(channel)
      @scheduler.at parsed_start_time do
        recorder = Recorder.new(show_name, frequency, id)
        recorder.start!
        sleep duration
        recorder.stop!
      end
    end
  
    def run!
      @scheduler.join
    end
  
    private
    def parse_time(time)
      return time if time.is_a?(Time)

      raise Exception, "Invalid time '#{time}'" unless time =~ /^(.*) (\d*) (\d*) (\d*):(\d*):(\d*)$/
      month, day, year, hour, minute, second = $1, $2, $3, $4, $5, $6

      month_number = @@months[month]
      raise Exception, "Unknown month '#{month}'" unless month_number

      Time.local(year, month_number, day, hour, minute, second)
    end
  end
end