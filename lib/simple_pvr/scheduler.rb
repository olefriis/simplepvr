require 'rufus/scheduler'
require File.dirname(__FILE__) + '/recorder'
require File.dirname(__FILE__) + '/pvr_logger'
require File.dirname(__FILE__) + '/pvr_initializer'

module SimplePvr
  class Scheduler
    def initialize
      @scheduler = Rufus::Scheduler.start_new
      @dao = PvrInitializer.dao
    end
  
    def add(show_name, options)
      channel, start_time, duration = options[:from], options[:at], options[:for]
      now = Time.now

      if start_time + duration <  now
        PvrLogger.info("Skipping recording of #{show_name}, since #{start_time} is in the past")
        return
      elsif start_time < now
        PvrLogger.info("Show #{show_name} is in progress - adjusting duration")
        duration -= (now - start_time)
      else
        PvrLogger.info("Scheduling #{show_name} for #{start_time}")
      end

      channel = @dao.channel_with_name(channel)
      @scheduler.at start_time do
        recorder = Recorder.new(show_name, channel)
        recorder.start!
        sleep duration
        recorder.stop!
      end
    end
  
    def run!
      @scheduler.join
    end
  end
end