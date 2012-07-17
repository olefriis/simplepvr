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
end

module SimplePvr
  class SimplePvr
    def initialize
      @scheduler = Scheduler.new
    end
  
    def record(show_name, options)
      if options[:at].nil?
        find_programmes(show_name, options)
      else
        @scheduler.add(show_name, options)
      end
    end
    
    def finish
      @scheduler.run!
    end
    
    private
    def find_programmes(show_name, options)
      channel = options[:from]
      @dao ||= Dao.new
      @dao.programmes_on_channel_with_title(channel, show_name).each do |programme|
        start_time = programme.start_time.to_time - 2.minutes.to_i
        duration = programme.duration + 7.minutes.to_i
        @scheduler.add(show_name, from:channel, at:start_time, for:duration)
      end
    end
  end
end
