require 'active_support/core_ext/numeric/time' # So we can say 60.minutes
require File.dirname(__FILE__) + '/pvr_initializer'
require File.dirname(__FILE__) + '/scheduler'

#
# Simple DSL to set up schedules
#

def schedule(&block)
  PvrInitializer.setup
  
  pvr = SimplePvr.new
  pvr.instance_eval &block
  pvr.finish
end

class SimplePvr
  def initialize
    @scheduler = Scheduler.new
  end
  
  def record(channel, show_name, start_time, duration)
    @scheduler.add(channel, show_name, start_time, duration)
  end
  
  def finish
    @scheduler.run!
  end
end
