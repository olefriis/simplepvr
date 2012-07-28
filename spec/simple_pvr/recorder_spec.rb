require 'simple_pvr/recorder'

describe SimplePvr::Recorder do
  before do
    @hdhomerun = double('HDHomeRun')
    SimplePvr::PvrInitializer.stub(hdhomerun: @hdhomerun)
    
    @channel = double('Channel', frequency:282000000, channel_id:1098)
    @recorder = SimplePvr::Recorder.new('Star Trek', @channel)
  end
  
  context 'when finding recording directories' do
    it 'records to directory with number 1 if nothing exists' do
      Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(false)
      FileUtils.should_receive(:makedirs).with('recordings/Star Trek/1')
      @hdhomerun.should_receive(:start_recording).with(282000000, 1098, 'recordings/Star Trek/1')
    
      @recorder.start!
    end
  
    it 'finds next number in sequence for new directory' do
      Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(true)
      Dir.should_receive(:new).with('recordings/Star Trek').and_return(['1', '2', '3'])
      FileUtils.should_receive(:makedirs).with('recordings/Star Trek/4')
      @hdhomerun.should_receive(:start_recording).with(282000000, 1098, 'recordings/Star Trek/4')
    
      @recorder.start!
    end
  
    it 'ignores random directories which are not sequence numbers' do
      Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(true)
      Dir.should_receive(:new).with('recordings/Star Trek').and_return(['4', 'random directory name', '..'])
      FileUtils.should_receive(:makedirs).with('recordings/Star Trek/5')
      @hdhomerun.should_receive(:start_recording).with(282000000, 1098, 'recordings/Star Trek/5')
    
      @recorder.start!
    end
  end
  
  it 'can stop recording as well' do
    Dir.stub(:exists? => false)
    FileUtils.stub(:makedirs)
    @hdhomerun.stub(:start_recording)
    @hdhomerun.should_receive(:stop_recording)
  
    @recorder.start!
    @recorder.stop!
  end
end
