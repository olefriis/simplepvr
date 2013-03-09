require 'simple_pvr'

describe SimplePvr::HDHomeRun do
  before do
    @pipe = double('pipe')
    IO.should_receive(:popen).with('hdhomerun_config discover').and_yield(@pipe)
    FileUtils.stub(:exists? => false)
  end

  context 'when initializing' do
    it 'discovers a device when present' do
      @pipe.stub(:read => 'hdhomerun device ABCDEF01 found at 10.0.0.4')

      SimplePvr::HDHomeRun.new.device_id.should == 'ABCDEF01'
    end
  
    it 'raises an exception when no device is present' do
      @pipe.stub(:read => 'no devices found')

      expect { SimplePvr::HDHomeRun.new }.to raise_error(Exception, 'No device found: no devices found')
    end
  end
  
  context 'when initialized' do
    before do
      @pipe.stub(:read => 'hdhomerun device ABCDEF01 found at 10.0.0.4')
      @hdhomerun = SimplePvr::HDHomeRun.new
      @hdhomerun.stub(:tuner_control_file).with(0).and_return('tuner0.lock')
      @hdhomerun.stub(:tuner_control_file).with(1).and_return('tuner1.lock')
      @file = File.open(File.dirname(__FILE__) + '/../resources/channels.txt', 'r:UTF-8')
    end
    
    after do
      @file.close
    end
  
    it 'can do a channel scan' do
      @hdhomerun.should_receive(:system).with('hdhomerun_config ABCDEF01 scan /tuner0 channels.txt')
      SimplePvr::Model::Channel.should_receive(:clear)
      File.should_receive(:open).with('channels.txt', 'r:UTF-8').and_yield(@file)
      SimplePvr::Model::Channel.should_receive(:add).with('DR K', 282000000, 1098)
      SimplePvr::Model::Channel.should_receive(:add).with('DR HD', 282000000, 1165)

      @hdhomerun.scan_for_channels
    end
    
    it 'can start recording on one tuner' do
      @hdhomerun.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner0/channel auto:282000000")
      @hdhomerun.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner0/program 1098")
      @hdhomerun.should_receive(:spawn) #... with a lot of arguments ...
      FileUtils.should_receive(:touch).with('tuner0.lock')
      
      @hdhomerun.start_recording(0, 282000000, 1098, 'test directory')
    end
    
    it 'can stop recording on one tuner' do
      @hdhomerun.stub(:system)
      @hdhomerun.stub(:spawn => 32)
      
      FileUtils.should_receive(:touch).with('tuner0.lock')
      FileUtils.should_receive(:rm).with('tuner0.lock')
      Process.should_receive(:wait).with(32)
      @hdhomerun.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner0/channel none")

      @hdhomerun.start_recording(0, 282000000, 1098, 'test directory')
      @hdhomerun.stop_recording(0)
    end
    
    it 'can start and stop recording on another tuner' do
      @hdhomerun.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner1/channel auto:282000000")
      @hdhomerun.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner1/program 1098")
      @hdhomerun.stub(:spawn => 32)
      FileUtils.should_receive(:touch).with('tuner1.lock')
      FileUtils.should_receive(:rm).with('tuner1.lock')
      Process.should_receive(:wait).with(32)
      @hdhomerun.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner1/channel none")

      @hdhomerun.start_recording(1, 282000000, 1098, 'test directory')
      @hdhomerun.stop_recording(1)
    end
  end
end