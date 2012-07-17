require 'simple_pvr/hd_home_run'

describe SimplePvr::HDHomeRun do
  before do
    @pipe = double('pipe')
    IO.should_receive(:popen).with('hdhomerun_config discover').and_yield(@pipe)
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
      @hd_home_run = SimplePvr::HDHomeRun.new
    end
  
    it 'can do a channel scan' do
      @hd_home_run.should_receive(:system).with('hdhomerun_config ABCDEF01 scan /tuner0 channels.txt')
    
      @hd_home_run.scan_for_channels
    end
    
    it 'can start recording' do
      @hd_home_run.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner0/channel auto:282000000")
      @hd_home_run.should_receive(:system).with("hdhomerun_config ABCDEF01 set /tuner0/program 1098")
      @hd_home_run.should_receive(:spawn).with("hdhomerun_config ABCDEF01 save /tuner0 \"test directory/stream.ts\"", [:out, :err]=>["test directory/hdhomerun_save.log", "w"])
      
      @hd_home_run.start_recording(282000000, 1098, 'test directory')
    end
    
    it 'can stop recording' do
      @hd_home_run.stub(:system)
      @hd_home_run.stub(:spawn => 32)
      Process.should_receive(:kill).with('INT', 32)

      @hd_home_run.start_recording(282000000, 1098, 'test directory')
      @hd_home_run.stop_recording
    end
  end
end