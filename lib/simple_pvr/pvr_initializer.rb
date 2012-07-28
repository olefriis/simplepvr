require File.dirname(__FILE__) + '/hd_home_run'
require File.dirname(__FILE__) + '/scheduler'
require File.dirname(__FILE__) + '/model/database_initializer'

module SimplePvr
  class PvrInitializer
    def self.setup
      Model::DatabaseInitializer.setup
      @hd_home_run = HDHomeRun.new
      @scheduler = Scheduler.new
      @scheduler.start

      @hd_home_run.scan_for_channels if Model::Channel.all.empty?
    end
    
    def self.dao
      @dao
    end
    
    def self.hd_home_run
      @hd_home_run
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