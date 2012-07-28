require 'simple_pvr/recording_planner'

describe SimplePvr::RecordingPlanner do
  MockChannelForRecordingPlanner = Struct.new(:id, :name)
  
  before do
    @dr_1 = MockChannelForRecordingPlanner.new(21, 'DR 1')
    @dr_k = MockChannelForRecordingPlanner.new(23, 'DR K')
    
    @dao = double('Dao')
    @scheduler = double('Scheduler')
    SimplePvr::PvrInitializer.stub(scheduler: @scheduler)
    SimplePvr::PvrInitializer.stub(dao: @dao)
    
    @recording_planner = SimplePvr::RecordingPlanner.new
  end
  
  it 'can set up simple recording' do
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes)
    ])

    @recording_planner.simple('Borgias', @dr_k, Time.local(2012, 7, 10, 20, 48), 67.minutes)
    @recording_planner.finish
  end
  
  it 'can set up schedules from channel and program title' do
    @dao.stub(:programmes_on_channel_with_title).with(@dr_k, 'Borgias').and_return([
      MockProgrammeForSimplePvr.new(@dr_k, Time.local(2012, 7, 10, 20, 50), 60.minutes),
      MockProgrammeForSimplePvr.new(@dr_k, Time.local(2012, 7, 17, 20, 50), 60.minutes)
    ])
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes),
      SimplePvr::Recording.new(@dr_k,'Borgias',  Time.local(2012, 7, 17, 20, 48), 67.minutes)
    ])

    @recording_planner.specification(title: 'Borgias', channel: @dr_k)
    @recording_planner.finish
  end
  
  it 'can set up schedules from program title only' do
    recordings = [
      SimplePvr::Recording.new(@dr_1, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes),
      SimplePvr::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes)
    ]
    @dao.stub(:programmes_with_title).with('Borgias').and_return([
      MockProgrammeForSimplePvr.new(@dr_1, Time.local(2012, 7, 10, 20, 50), 60.minutes),
      MockProgrammeForSimplePvr.new(@dr_k, Time.local(2012, 7, 17, 20, 50), 60.minutes)
    ])
    @scheduler.should_receive(:recordings=).with(recordings)

    @recording_planner.specification(title: 'Borgias')
    @recording_planner.finish
  end
end