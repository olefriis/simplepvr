require File.dirname(__FILE__) + '/hdhomerun'
require File.dirname(__FILE__) + '/scheduler'
require File.dirname(__FILE__) + '/model/database_initializer'

module SimplePvr
  class PvrInitializer
    def self.setup
      Model::DatabaseInitializer.setup
      @hdhomerun = HDHomeRun.new
      @scheduler = Scheduler.new
      @scheduler.start

      @hdhomerun.scan_for_channels if Model::Channel.all.empty?
    end
    
    def self.dao
      @dao
    end
    
    def self.hdhomerun
      @hdhomerun
    end
    
    def self.scheduler
      @scheduler
    end
    
    def self.sleep_forever
      forever = 6000.days
      sleep forever
    end
  end
end