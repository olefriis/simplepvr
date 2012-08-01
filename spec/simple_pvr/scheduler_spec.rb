require 'simple_pvr/scheduler'

describe SimplePvr::Scheduler do
  before do
    @channel = double('Channel DR K', name: 'DR K', frequency: 282000000, channel_id: 1098)
    @channel_dr1 = double('Channel DR 1', name: 'DR 1', frequency: 290000000, channel_id: 1099)
    
    @scheduler = SimplePvr::Scheduler.new
  end
  
  it 'leaves recordings that are in the future' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    Time.stub(:now => start_time.advance(hours: -1))

    @scheduler.recordings = [SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)]
    @scheduler.process
  end
  
  it 'starts recordings at start time' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    starting_recording = SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
    Time.stub(:now => start_time)
    SimplePvr::Recorder.stub(:new).with(starting_recording).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)

    @scheduler.recordings = [starting_recording]
    @scheduler.process
  end
  
  it 'starts recordings that are in progress' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    recording_in_progress = SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
    Time.stub(:now => start_time.advance(minutes: 30))
    SimplePvr::Recorder.stub(:new).with(recording_in_progress).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)

    @scheduler.recordings = [recording_in_progress]
    @scheduler.process
  end
  
  it 'ends recordings at end time' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    ending_recording = SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
    SimplePvr::Recorder.stub(:new).with(ending_recording).and_return(@recorder = double('Recorder'))
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
    passed_recording = SimplePvr::Recording.new(@channel, 'Borgia', start_time - 65.minutes, 60.minutes)
    Time.stub(:now => start_time)
    
    @scheduler.recordings = [passed_recording]
    @scheduler.process
  end
  
  it 'knows which programmes are being recorded' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30)
    Time.stub(:now => start_time.advance(hours: -1))
    scheduled_programme = double(id: 2)
    unscheduled_programme = double(id: 3)

    @scheduler.recordings = [SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes, scheduled_programme)]
    @scheduler.is_scheduled?(scheduled_programme).should be_true
    @scheduler.is_scheduled?(unscheduled_programme).should be_false
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

    @scheduler.recordings = [SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)]
    @scheduler.process

    @scheduler.status_text.should == "Recording 'Borgia' on channel 'DR K'"
  end
  
  context 'when updating existing recordings' do
    it 'leaves running recording if new recording is equal' do
      start_time = Time.local(2012, 7, 15, 20, 15, 30)
      continuing_recording = SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
      Time.stub(:now => start_time)
      SimplePvr::Recorder.stub(:new).with(continuing_recording).and_return(@recorder = double('Recorder'))
      @recorder.should_receive(:start!)

      @scheduler.recordings = [continuing_recording]
      @scheduler.process

      @scheduler.recordings = [SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)]
      @scheduler.process
    end
    
    it 'stops existing recording if not present in new recording list' do
      start_time = Time.local(2012, 7, 15, 20, 15, 30)
      stopping_recording = SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
      upcoming_recording = SimplePvr::Recording.new(@channel, 'Borgia', start_time + 10.minutes, 60.minutes)
      Time.stub(:now => start_time)
      SimplePvr::Recorder.stub(:new).with(stopping_recording).and_return(@recorder = double('Recorder'))
      @recorder.should_receive(:start!)

      @scheduler.recordings = [stopping_recording]
      @scheduler.process

      @recorder.should_receive(:stop!)

      @scheduler.recordings = [upcoming_recording]
      @scheduler.process
    end
    
    it 'stops existing recording and starts new recording if new recording list has other current recording' do
      start_time = Time.local(2012, 7, 15, 20, 15, 30)
      stopping_recording = SimplePvr::Recording.new(@channel, 'Borgia', start_time, 60.minutes)
      starting_recording = SimplePvr::Recording.new(@channel_dr1, 'Sports', start_time, 60.minutes)
      Time.stub(:now => start_time)
      SimplePvr::Recorder.stub(:new).with(stopping_recording).and_return(@old_recorder = double('Recorder'))
      SimplePvr::Recorder.stub(:new).with(starting_recording).and_return(@new_recorder = double('New recorder'))
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