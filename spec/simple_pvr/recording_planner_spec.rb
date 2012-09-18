require 'simple_pvr'

describe SimplePvr::RecordingPlanner do
  before do
    @dr_1 = double(id: 21, name: 'DR 1')
    @dr_k = double(id: 23, name: 'DR K')
    
    @scheduler = double('Scheduler')
    SimplePvr::PvrInitializer.stub(scheduler: @scheduler)
    SimplePvr::PvrInitializer.stub(dao: @dao)
    
    @recording_planner = SimplePvr::RecordingPlanner.new
  end
  
  it 'can set up schedules from channel and program title' do
    @programme_1 = double(channel:@dr_k, start_time: Time.local(2012, 7, 10, 20, 50), duration: 60.minutes)
    @programme_2 = double(channel:@dr_k, start_time: Time.local(2012, 7, 17, 20, 50), duration: 60.minutes)
    SimplePvr::Model::Programme.stub(:on_channel_with_title).with(@dr_k, 'Borgias').and_return([@programme_1, @programme_2])
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes, @programme_1),
      SimplePvr::Recording.new(@dr_k,'Borgias',  Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_2)
    ])

    @recording_planner.specification(title: 'Borgias', channel: @dr_k)
    @recording_planner.finish
  end

  it 'can set up schedules from channel and program title and start time' do
    programme_title = 'Borgias'
    start_time_1 = Time.local(2012, 7, 10, 20, 50)
    start_time_2 = Time.local(2012, 7, 17, 20, 50)
    programme_duration = 60.minutes

    @programme_to_be_ignored = double(channel:@dr_k, start_time: start_time_1, duration: programme_duration)
    @programme_to_be_recorded = double(channel:@dr_k, start_time: start_time_2, duration: programme_duration)
    SimplePvr::Model::Programme.stub(:on_channel_with_title_and_start_time).with(@dr_k, programme_title, start_time_2).and_return([@programme_to_be_recorded])

    @scheduler.should_receive(:recordings=).with([
         SimplePvr::Recording.new(@dr_k, programme_title, start_time_2.advance(minutes: -2), 2.minutes + programme_duration + 5.minutes, @programme_to_be_recorded)
    ])

    @recording_planner.specification(title: 'Borgias', channel: @dr_k, start_time: start_time_2)
    @recording_planner.finish
  end

  it 'can set up schedules from program title only' do
    @programme_1 = double(channel: @dr_1, start_time: Time.local(2012, 7, 10, 20, 50), duration: 60.minutes)
    @programme_2 = double(channel: @dr_k, start_time: Time.local(2012, 7, 17, 20, 50), duration: 60.minutes)
    SimplePvr::Model::Programme.stub(:with_title).with('Borgias').and_return([@programme_1, @programme_2])
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Recording.new(@dr_1, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes, @programme_1),
      SimplePvr::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_2)
    ])

    @recording_planner.specification(title: 'Borgias')
    @recording_planner.finish
  end
end