require File.dirname(__FILE__) + '/hd_home_run'

module SimplePvr
  class PvrInitializer
    def self.setup
      HDHomeRun.new.scan_for_channels unless File.exists?('channels.txt')
    end
  end
end