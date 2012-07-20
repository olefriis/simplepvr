require File.dirname(__FILE__) + '/dao'
require File.dirname(__FILE__) + '/hd_home_run'

module SimplePvr
  class PvrInitializer
    def self.setup
      @dao = Dao.new
      @hd_home_run = HDHomeRun.new(@dao)

      @hd_home_run.scan_for_channels if @dao.number_of_channels == 0
    end
    
    def self.dao
      @dao
    end
    
    def self.hd_home_run
      @hd_home_run
    end
    
    def self.sleep_forever
      forever = 6000.days
      sleep forever
    end
  end
end