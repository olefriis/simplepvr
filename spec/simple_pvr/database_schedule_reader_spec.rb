require 'simple_pvr/database_schedule_reader'

describe SimplePvr::DatabaseScheduleReader do
  MockChannelForDatabaseScheduleReader = Struct.new(:id, :name)
  
  before do
    @recording_planner = double('RecordingPlanner')
    SimplePvr::RecordingPlanner.stub(new: @recording_planner)

    @dao = double('dao')
    SimplePvr::PvrInitializer.stub(:dao => @dao)

    @dr_k = MockChannelForDatabaseScheduleReader.new(23, 'DR K')
  end
  
  it 'resets the recordings when no schedules are present' do
    @dao.stub(:schedules => [])
    @recording_planner.should_receive(:finish)
    
    SimplePvr::DatabaseScheduleReader.read
  end
  
  it 'creates recordings with titles' do
    @dao.stub(:schedules => [SimplePvr::Schedule.new(title: 'Sports')])
    @recording_planner.should_receive(:specification).with(title: 'Sports', channel: nil)
    @recording_planner.should_receive(:finish)
    
    SimplePvr::DatabaseScheduleReader.read
  end
  
  it 'creates recordings with titles and channels' do
    @dao.stub(:schedules => [SimplePvr::Schedule.new(title: 'Sports', channel: @dr_k)])
    @recording_planner.should_receive(:specification).with(title: 'Sports', channel: @dr_k)
    @recording_planner.should_receive(:finish)
    
    SimplePvr::DatabaseScheduleReader.read
  end
end