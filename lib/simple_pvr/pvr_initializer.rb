require File.dirname(__FILE__) + '/hd_home_run'

module SimplePvr
  class PvrInitializer
    def self.setup
      @dao = Dao.new
      @hd_home_run = HDHomeRun.new(@dao)

      @hd_home_run.scan_for_channels unless File.exists?('channels.txt')
    end
    
    def self.dao
      @dao
    end
    
    def self.hd_home_run
      @hd_home_run
    end
  end
end