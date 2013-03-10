module SimplePvr
  class PvrInitializer
    def self.setup
      Model::DatabaseInitializer.setup
      setup_with_hdhomerun(HDHomeRun.new)
      @hdhomerun.scan_for_channels if Model::Channel.all.empty?
    end
    
    def self.setup_for_integration_test
      Model::DatabaseInitializer.prepare_for_test
      setup_with_hdhomerun(HDHomeRunFake.new)
    end
    
    def self.hdhomerun
      @hdhomerun
    end
    
    def self.recording_manager
      @recording_manager
    end
    
    def self.scheduler
      @scheduler
    end

    def self.rackup_file_path
      File.dirname(__FILE__) + '/server/config.ru'
    end
    
    def self.rack_maps_file
      File.read(File.dirname(__FILE__) + '/server/rack_maps.rb')
    end
    
    def self.sleep_forever
      forever = 6000.days
      sleep forever
    end
    
    private
    def self.setup_with_hdhomerun(hdhomerun)
      @hdhomerun = hdhomerun
      @recording_manager = RecordingManager.new
      @scheduler = Scheduler.new
      @scheduler.start
    end
  end
end