require 'simple_pvr'

describe SimplePvr::RecordingPlanner do
  before do
    SimplePvr::Model::DatabaseInitializer.prepare_for_test
    SimplePvr::Model::DatabaseInitializer.clear
    @dr_1 = SimplePvr::Model::Channel.create(name: 'DR 1')
    @dr_k = SimplePvr::Model::Channel.create(name: 'DR K')
    @start_time_1, @start_time_2 = Time.local(2012, 7, 10, 20, 50), Time.local(2012, 7, 17, 20, 50)
    @programme_title = 'Borgias'
    @programme_duration = 60.minutes.to_i
    
    @scheduler = double('Scheduler')
    SimplePvr::PvrInitializer.stub(scheduler: @scheduler)
  end
  
  it 'resets the recordings when no schedules exist' do
    SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_k, start_time: @start_time_1, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: @programme_title + "-", channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([])
    
    SimplePvr::RecordingPlanner.read
  end
  
  it 'can set up schedules from channel and programme title' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', channel: @dr_k)
    @programme_1 = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_k, start_time: @start_time_1, duration: @programme_duration)
    @programme_2 = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: @programme_title + "-", channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes, @programme_1),
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_2)
    ])

    SimplePvr::RecordingPlanner.read
  end

  it 'can set up schedules from channel and programme title and start time' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', channel: @dr_k, start_time: @start_time_2)
    SimplePvr::Model::Programme.create(title: @programme_title, channel:@dr_k, start_time: @start_time_1, duration: @programme_duration)
    @programme_to_be_recorded = SimplePvr::Model::Programme.create(title: @programme_title, channel:@dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([
         SimplePvr::Model::Recording.new(@dr_k, @programme_title, @start_time_2.advance(minutes: -2), 2.minutes + @programme_duration + 5.minutes, @programme_to_be_recorded)
    ])

    SimplePvr::RecordingPlanner.read
  end

  it 'can set up schedules from programme title only' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias')
    @programme_1 = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @start_time_1, duration: @programme_duration)
    @programme_2 = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: @programme_title + '-', channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes, @programme_1),
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_2)
    ])

    SimplePvr::RecordingPlanner.read
  end
  
  it 'ignores programmes for which exceptions exist' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias')
    SimplePvr::Model::Schedule.create(type: :exception, title: 'Borgias', channel: @dr_1, start_time: @start_time_1)
    SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @start_time_1, duration: @programme_duration)
    @programme_to_be_recorded = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_to_be_recorded)
    ])

    SimplePvr::RecordingPlanner.read
  end
end