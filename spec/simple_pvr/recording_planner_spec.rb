require 'simple_pvr/recording_planner'

describe SimplePvr::RecordingPlanner do
  before do
    @dr_1 = double(id: 21, name: 'DR 1')
    @dr_k = double(id: 23, name: 'DR K')
    
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
    SimplePvr::Model::Programme.stub(:on_channel_with_title).with(@dr_k, 'Borgias').and_return([
      double(channel:@dr_k, start_time: Time.local(2012, 7, 10, 20, 50), duration: 60.minutes),
      double(channel:@dr_k, start_time: Time.local(2012, 7, 17, 20, 50), duration: 60.minutes)
    ])
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes),
      SimplePvr::Recording.new(@dr_k,'Borgias',  Time.local(2012, 7, 17, 20, 48), 67.minutes)
    ])

    @recording_planner.specification(title: 'Borgias', channel: @dr_k)
    @recording_planner.finish
  end
  
  it 'can set up schedules from program title only' do
    SimplePvr::Model::Programme.stub(:with_title).with('Borgias').and_return([
      double(channel: @dr_1, start_time: Time.local(2012, 7, 10, 20, 50), duration: 60.minutes),
      double(channel: @dr_k, start_time: Time.local(2012, 7, 17, 20, 50), duration: 60.minutes)
    ])
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Recording.new(@dr_1, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes),
      SimplePvr::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes)
    ])

    @recording_planner.specification(title: 'Borgias')
    @recording_planner.finish
  end
end