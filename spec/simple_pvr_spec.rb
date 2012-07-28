require 'simple_pvr'

describe 'SimplePvr' do
  MockProgrammeForSimplePvr = Struct.new(:channel, :start_time, :duration)
  MockChannelForSimplePvr = Struct.new(:id, :name)
  
  before do
    @dao = double('Dao')
    SimplePvr::PvrInitializer.stub(dao: @dao)
    
    @dr_k = MockChannelForSimplePvr.new(23, 'DR K')
    @tv_2 = MockChannelForSimplePvr.new(25, 'TV 2')
    @dao.stub(:channel_with_name).with('DR K').and_return(@dr_k)
    @dao.stub(:channel_with_name).with('TV 2').and_return(@tv_2)
    
    @recording_planner = double('RecordingPlanner')
    SimplePvr::RecordingPlanner.stub(new: @recording_planner)
    
    # Always initializes the system and sleeps forever
    SimplePvr::PvrInitializer.should_receive(:setup)
    @recording_planner.stub(:finish)
    SimplePvr::PvrInitializer.stub(:sleep_forever)
  end
  
  it 'can set up simple schedules' do
    @recording_planner.should_receive(:simple).with('Borgias', @dr_k, Time.local(2012, 7, 10, 20, 46), 60.minutes)
    @recording_planner.should_receive(:simple).with('Sports news', @tv_2, Time.local(2012, 7, 11, 12, 15), 20.minutes)
    
    schedule do
      record 'Borgias', from:'DR K', at:Time.local(2012, 7, 10, 20, 46), for:60.minutes
      record 'Sports news', from:'TV 2', at:Time.local(2012, 7, 11, 12, 15), for:20.minutes
    end
  end
  
  it 'complains when setting up simple schedules without duration' do
    start_time = Time.local(2012, 7, 10, 20, 46)
    expect {
      schedule do
        record 'Borgias', from:'DR K', at:start_time
      end
    }.to raise_error "No duration specified for recording of 'Borgias' from 'DR K' at '#{start_time}'"
  end
  
  it 'can set up schedules from channel and program title' do
    @recording_planner.should_receive(:specification).with(title: 'Borgias', channel: @dr_k)

    schedule do
      record 'Borgias', from:'DR K'
    end
  end
  
  it 'can set up schedules from program title only' do
    @recording_planner.should_receive(:specification).with(title: 'Borgias')

    schedule do
      record 'Borgias'
    end
  end
end