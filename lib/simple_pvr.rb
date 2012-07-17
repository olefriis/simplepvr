require 'active_support/core_ext/numeric/time' # So we can say 60.minutes
require File.dirname(__FILE__) + '/simple_pvr/pvr_initializer'
require File.dirname(__FILE__) + '/simple_pvr/scheduler'

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
      @scheduler.add(show_name, options)
    end
  
    def finish
      @scheduler.run!
    end
  end
end
