require 'simple_pvr/hd_home_run'

describe SimplePvr::HDHomeRun do
  before do
    @dao = double('dao')
    @pipe = double('pipe')
    IO.should_receive(:popen).with('hdhomerun_config discover').and_yield(@pipe)
    FileUtils.stub(:exists? => false)
  end

  context 'when initializing' do
    it 'discovers a device when present' do
      @pipe.stub(:read => 'hdhomerun device ABCDEF01 found at 10.0.0.4')

      SimplePvr::HDHomeRun.new(@dao).device_id.should == 'ABCDEF01'
    end
  
    it 'raises an exception when no device is present' do
      @pipe.stub(:read => 'no devices found')

      expect { SimplePvr::HDHomeRun.new(@dao) }.to raise_error(Exception, 'No device found: no devices found')
    end
  end
  
  context 'when initialized' do
    before do
      @pipe.stub(:read => 'hdhomerun device ABCDEF01 found at 10.0.0.4')
      @hd_home_run = SimplePvr::HDHomeRun.new(@dao)
      @hd_home_run.stub(:tuner_control_file => 'tuner0.lock')
      @file = File.open(File.dirname(__FILE__) + '/../resources/channels.txt', 'r:UTF-8')
    end
    
    after do
      @file.close
    end
  
    it 'can do a channel scan' do
      @hd_home_run.should_receive(:system).with('hdhomerun_config ABCDEF01 scan /tuner0 channels.txt')
      @dao.should_receive(:clear_channels)
      File.should_receive(:open).with('channels.txt', 'r:UTF-8').and_yield(@file)
      @dao.should_receive(:add_channel).with('DR K', 282000000, 1098)
      @dao.should_receive(:add_channel).with('DR HD', 282000000, 1165)

      @hd_home_run.scan_for_channels
    end
    
    it 'can start recording' do
      @hd_home_run.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner0/channel auto:282000000")
      @hd_home_run.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner0/program 1098")
      @hd_home_run.should_receive(:spawn) #... with a lot of arguments ...
      FileUtils.should_receive(:touch).with('tuner0.lock')
      
      @hd_home_run.start_recording(282000000, 1098, 'test directory')
    end
    
    it 'can stop recording' do
      @hd_home_run.stub(:system)
      @hd_home_run.stub(:spawn => 32)
      
      FileUtils.should_receive(:touch).with('tuner0.lock')
      FileUtils.should_receive(:rm).with('tuner0.lock')
      Process.should_receive(:wait).with(32)

      @hd_home_run.start_recording(282000000, 1098, 'test directory')
      @hd_home_run.stop_recording
    end
  end
end