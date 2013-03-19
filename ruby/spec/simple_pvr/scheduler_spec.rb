require 'simple_pvr'

describe SimplePvr::Scheduler do
  before do
    @channel = double('Channel DR K', name: 'DR K', frequency: 282000000, channel_id: 1098)
    @channel_dr1 = double('Channel DR 1', name: 'DR 1', frequency: 290000000, channel_id: 1099)
    
    @scheduler = SimplePvr::Scheduler.new
  end
  
  it 'leaves recordings that are in the future' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    Time.stub(:now => start_time.advance(hours: -1))

    @scheduler.recordings = [SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)]
    @scheduler.process
  end
  
  it 'marks conflicting future recordings' do
    first_start_time = Time.now.advance(days: 1)
    second_start_time = Time.now.advance(days: 1, minutes: 10)
    third_start_time = Time.now.advance(days: 1, minutes: 20)
    fourth_start_time = Time.now.advance(days: 2)
    first_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', first_start_time, 60.minutes)
    second_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', second_start_time, 60.minutes)
    third_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', third_start_time, 60.minutes)
    fourth_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', fourth_start_time, 60.minutes)

    @scheduler.recordings = [first_recording, third_recording, second_recording]
    
    first_recording.should_not be_conflicting
    second_recording.should_not be_conflicting
    third_recording.should be_conflicting
    fourth_recording.should_not be_conflicting
  end
  
  it 'starts recordings at start time' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    starting_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
    Time.stub(:now => start_time)
    SimplePvr::Recorder.stub(:new).with(0, starting_recording).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)

    @scheduler.recordings = [starting_recording]
    @scheduler.process
  end
  
  it 'starts recordings that are in progress' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    recording_in_progress = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
    Time.stub(:now => start_time.advance(minutes: 30))
    SimplePvr::Recorder.stub(:new).with(0, recording_in_progress).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)

    @scheduler.recordings = [recording_in_progress]
    @scheduler.process
  end
  
  it 'can start two recordings at once' do
    first_start_time = Time.local(2012, 7, 15, 19, 45, 30)
    second_start_time = Time.local(2012, 7, 15, 20, 15, 30)
    recording_in_progress = SimplePvr::Model::Recording.new(@channel, 'Borgia', first_start_time, 60.minutes)
    starting_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', second_start_time, 60.minutes)
    Time.stub(:now => second_start_time)
    SimplePvr::Recorder.stub(:new).with(0, recording_in_progress).and_return(@recorder0 = double('Recorder'))
    SimplePvr::Recorder.stub(:new).with(1, starting_recording).and_return(@recorder1 = double('Recorder'))
    @recorder0.should_receive(:start!)
    @recorder1.should_receive(:start!)

    @scheduler.recordings = [recording_in_progress, starting_recording]
    @scheduler.process
  end
  
  it 'rejects third recording at once, and marks the third recording as conflicting' do
    first_start_time = Time.local(2012, 7, 15, 19, 45, 30)
    second_start_time = Time.local(2012, 7, 15, 20, 15, 30)
    third_start_time = Time.local(2012, 7, 15, 20, 20, 0)
    recording_in_progress = SimplePvr::Model::Recording.new(@channel, 'Borgia', first_start_time, 60.minutes)
    starting_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', second_start_time, 60.minutes)
    rejected_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', third_start_time, 60.minutes)
    Time.stub(:now => second_start_time)
    SimplePvr::Recorder.stub(:new).with(0, recording_in_progress).and_return(@recorder0 = double('Recorder'))
    SimplePvr::Recorder.stub(:new).with(1, starting_recording).and_return(@recorder1 = double('Recorder'))
    @recorder0.should_receive(:start!)
    @recorder1.should_receive(:start!)

    @scheduler.recordings = [recording_in_progress, starting_recording, rejected_recording]
    @scheduler.process
    
    recording_in_progress.should_not be_conflicting
    starting_recording.should_not be_conflicting
    rejected_recording.should be_conflicting
  end
  
  it 'ends recordings at end time' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    ending_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
    SimplePvr::Recorder.stub(:new).with(0, ending_recording).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)
    Time.stub(:now => start_time)

    @scheduler.recordings = [ending_recording]
    @scheduler.process

    @recorder.should_receive(:stop!)
    Time.stub(:now => start_time.advance(hours: 1, minutes: 1))

    @scheduler.process
  end
  
  it 'skips recordings that have passed' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    passed_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time - 65.minutes, 60.minutes)
    Time.stub(:now => start_time)
    
    @scheduler.recordings = [passed_recording]
    @scheduler.process
  end
  
  it 'knows which programmes are being recorded' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    Time.stub(:now => start_time.advance(hours: -1))
    scheduled_programme = double(id: 2)
    unscheduled_programme = double(id: 3)

    @scheduler.recordings = [SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes, scheduled_programme)]
    @scheduler.scheduled?(scheduled_programme).should be_true
    @scheduler.scheduled?(unscheduled_programme).should be_false
  end
  
  it 'gives idle status when nothing is recording' do
    @scheduler.recordings = []
    @scheduler.process

    @scheduler.status_text.should == 'Idle'
  end

  it 'gives recording status when recording' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    Time.stub(:now => start_time.advance(minutes: 30))
    SimplePvr::Recorder.stub(new: (@recorder = double('Recorder')))
    @recorder.stub(:start!)

    @scheduler.recordings = [SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)]
    @scheduler.process

    @scheduler.status_text.should == "Recording 'Borgia' on channel 'DR K'"
  end
  
  context 'when updating existing recordings' do
    it 'leaves running recording if new recording is equal' do
      start_time = Time.local(2012, 7, 15, 20, 15, 30)
      continuing_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
      Time.stub(:now => start_time)
      SimplePvr::Recorder.stub(:new).with(0, continuing_recording).and_return(@recorder = double('Recorder'))
      @recorder.should_receive(:start!)

      @scheduler.recordings = [continuing_recording]
      @scheduler.process

      @scheduler.recordings = [SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)]
      @scheduler.process
    end
    
    it 'stops existing recording if not present in new recording list' do
      start_time = Time.local(2012, 7, 15, 20, 15, 30)
      stopping_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
      upcoming_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time + 10.minutes, 60.minutes)
      Time.stub(:now => start_time)
      SimplePvr::Recorder.stub(:new).with(0, stopping_recording).and_return(@recorder = double('Recorder'))
      @recorder.should_receive(:start!)

      @scheduler.recordings = [stopping_recording]
      @scheduler.process

      @recorder.should_receive(:stop!)

      @scheduler.recordings = [upcoming_recording]
      @scheduler.process
    end
    
    it 'stops existing recording and starts new recording if new recording list has other current recording' do
      start_time = Time.local(2012, 7, 15, 20, 15, 30)
      stopping_recording = SimplePvr::Model::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
      starting_recording = SimplePvr::Model::Recording.new(@channel_dr1, 'Sports', start_time, 60.minutes)
      Time.stub(:now => start_time)
      SimplePvr::Recorder.stub(:new).with(0, stopping_recording).and_return(@old_recorder = double('Recorder'))
      SimplePvr::Recorder.stub(:new).with(0, starting_recording).and_return(@new_recorder = double('New recorder'))
      @old_recorder.should_receive(:start!)

      @scheduler.recordings = [stopping_recording]
      @scheduler.process

      @old_recorder.should_receive(:stop!)
      @new_recorder.should_receive(:start!)

      @scheduler.recordings = [starting_recording]
      @scheduler.process
    end
  end
end