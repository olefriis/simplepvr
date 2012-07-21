require 'active_support/core_ext/numeric/time' # So we can say 60.minutes
require File.dirname(__FILE__) + '/simple_pvr/pvr_initializer'
require File.dirname(__FILE__) + '/simple_pvr/scheduler'
require File.dirname(__FILE__) + '/simple_pvr/dao'

#
# Simple DSL to set up schedules
#

def schedule(&block)
  SimplePvr::PvrInitializer.setup
  
  pvr = SimplePvr::SimplePvr.new
  pvr.instance_eval &block
  pvr.finish

  SimplePvr::PvrInitializer.sleep_forever
end

module SimplePvr
  class SimplePvr
    def initialize
      @dao = PvrInitializer.dao
      @recordings = []
    end
  
    def record(show_name, options={})
      if options[:at].nil? && options[:from].nil?
        record_programmes_with_title(show_name)
      elsif options[:at].nil?
        record_programmes_with_title_on_channel(show_name, options)
      else
        record_from_timestamp_and_duration(show_name, options)
      end
    end
    
    def finish
      scheduler = Scheduler.new
      scheduler.recordings = @recordings
      scheduler.start
    end
    
    private
    def record_programmes_with_title(show_name)
      schedule_programmes(show_name, @dao.programmes_with_title(show_name))
    end
    
    def record_programmes_with_title_on_channel(show_name, options)
      channel = options[:from]
      schedule_programmes(show_name, @dao.programmes_on_channel_with_title(channel, show_name))
    end
    
    def record_from_timestamp_and_duration(show_name, options)
      if options[:for].nil?
        raise Exception, "No duration specified for recording of '#{show_name}' from '#{options[:from]}' at '#{options[:at]}'"
      end

      add_recording(options[:from], show_name, options[:at], options[:for])
    end
    
    def schedule_programmes(show_name, programmes)
      programmes.each do |programme|
        start_time = programme.start_time.to_time - 2.minutes
        duration = programme.duration + 7.minutes
        add_recording(programme.channel.name, show_name, start_time, duration)
      end
    end
    
    def add_recording(channel, show_name, start_time, duration)
      puts "Adding #{channel}, #{show_name}, #{start_time}, #{duration}"
      @recordings << Recording.new(channel, show_name, start_time, duration)
    end
  end
end
