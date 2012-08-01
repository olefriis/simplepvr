require 'simple_pvr/recorder'

describe SimplePvr::Recorder do
  before do
    @channel = SimplePvr::Model::Channel.new(frequency: 282000000, channel_id: 1098)
    @recording = SimplePvr::Recording.new(@channel, 'Star Trek', 'start time', 'duration')

    @hdhomerun = double('HDHomeRun')
    SimplePvr::PvrInitializer.stub(hdhomerun: @hdhomerun)

    @recording_manager = double('RecordingManager')
    @recording_manager.stub(:create_directory_for_recording).with(@recording).and_return('recording directory')  
    SimplePvr::PvrInitializer.stub(recording_manager: @recording_manager)
    
    @recorder = SimplePvr::Recorder.new(@recording)
  end
  
  it 'can start recording' do
    @hdhomerun.should_receive(:start_recording).with(282000000, 1098, 'recording directory')
  
    @recorder.start!
  end
  
  it 'can stop recording as well' do
    @hdhomerun.stub(:start_recording)
    @hdhomerun.should_receive(:stop_recording)
  
    @recorder.start!
    @recorder.stop!
  end
end
