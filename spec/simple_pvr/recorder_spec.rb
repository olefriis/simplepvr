require 'simple_pvr/recorder'

describe SimplePvr::Recorder do
  before do
    @hd_home_run = double('HDHomeRun')
    SimplePvr::PvrInitializer.stub(:hd_home_run => @hd_home_run)
    
    @recorder = SimplePvr::Recorder.new('Star Trek', 282000000, 1098)
  end
  
  context 'when finding recording directories' do
    it 'records to directory with number 1 if nothing exists' do
      Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(false)
      FileUtils.should_receive(:makedirs).with('recordings/Star Trek/1')
      @hd_home_run.should_receive(:start_recording).with(282000000, 1098, 'recordings/Star Trek/1')
    
      @recorder.start!
    end
  
    it 'finds next number in sequence for new directory' do
      Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(true)
      Dir.should_receive(:new).with('recordings/Star Trek').and_return(['1', '2', '3'])
      FileUtils.should_receive(:makedirs).with('recordings/Star Trek/4')
      @hd_home_run.should_receive(:start_recording).with(282000000, 1098, 'recordings/Star Trek/4')
    
      @recorder.start!
    end
  
    it 'ignores random directories which are not sequence numbers' do
      Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(true)
      Dir.should_receive(:new).with('recordings/Star Trek').and_return(['4', 'random directory name', '..'])
      FileUtils.should_receive(:makedirs).with('recordings/Star Trek/5')
      @hd_home_run.should_receive(:start_recording).with(282000000, 1098, 'recordings/Star Trek/5')
    
      @recorder.start!
    end
  end
  
  it 'can stop recording as well' do
    Dir.stub(:exists? => false)
    FileUtils.stub(:makedirs)
    @hd_home_run.stub(:start_recording)
    @hd_home_run.should_receive(:stop_recording)
  
    @recorder.start!
    @recorder.stop!
  end
end
