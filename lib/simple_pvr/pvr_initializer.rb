require File.dirname(__FILE__) + '/hd_home_run'

class PvrInitializer
  def self.setup
    HDHomeRun.new.scan_for_channels unless File.exists?('channels.txt')
  end
end