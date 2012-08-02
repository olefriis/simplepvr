require 'simple_pvr/database_schedule_reader'

describe SimplePvr::DatabaseScheduleReader do
  before do
    @recording_planner = double('RecordingPlanner')
    SimplePvr::RecordingPlanner.stub(new: @recording_planner)

    @dao = double('dao')
    SimplePvr::PvrInitializer.stub(:dao => @dao)

    @dr_k = double(id: 23, name: 'DR K')
  end
  
  it 'resets the recordings when no schedules are present' do
    SimplePvr::Model::Schedule.stub(all: [])
    @recording_planner.should_receive(:finish)
    
    SimplePvr::DatabaseScheduleReader.read
  end
  
  it 'creates recordings with titles' do
    SimplePvr::Model::Schedule.stub(all: [SimplePvr::Model::Schedule.new(title: 'Sports')])
    @recording_planner.should_receive(:specification).with(title: 'Sports', channel: nil)
    @recording_planner.should_receive(:finish)
    
    SimplePvr::DatabaseScheduleReader.read
  end
  
  it 'creates recordings with titles and channels' do
    SimplePvr::Model::Schedule.stub(all: [SimplePvr::Model::Schedule.new(title: 'Sports', channel: @dr_k)])
    @recording_planner.should_receive(:specification).with(title: 'Sports', channel: @dr_k)
    @recording_planner.should_receive(:finish)
    
    SimplePvr::DatabaseScheduleReader.read
  end
end