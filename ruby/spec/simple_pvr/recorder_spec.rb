require 'simple_pvr'

describe SimplePvr::Recorder do
  before do
    @channel = SimplePvr::Model::Channel.new(frequency: 282000000, channel_id: 1098)
    @recording = SimplePvr::Model::Recording.new(@channel, 'Star Trek', 'start time', 'duration')

    @hdhomerun = double('HDHomeRun')
    SimplePvr::PvrInitializer.stub(hdhomerun: @hdhomerun)

    @recording_manager = double('RecordingManager')
    @recording_manager.stub(:create_directory_for_recording).with(@recording).and_return('recording directory')  
    SimplePvr::PvrInitializer.stub(recording_manager: @recording_manager)
    
    @recorder = SimplePvr::Recorder.new(1, @recording)
  end
  
  it 'can start recording' do
    @hdhomerun.should_receive(:start_recording).with(1, 282000000, 1098, 'recording directory')
  
    @recorder.start!
  end
  
  it 'can stop recording as well, and creates a thumbnail' do
    @hdhomerun.stub(:start_recording)
    @hdhomerun.should_receive(:stop_recording).with(1)
    SimplePvr::Ffmpeg.should_receive(:create_thumbnail_for).with('recording directory')
  
    @recorder.start!
    @recorder.stop!
  end
end
