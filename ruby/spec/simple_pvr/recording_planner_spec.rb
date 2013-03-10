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

  it 'can set up schedules from channel, programme title, and start time' do
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
  
  it 'can set up schedules for specific days of the week' do
    @monday = Time.local(2012, 12, 10, 20, 50)
    @tuesday, @wednesday, @thursday, @friday, @saturday, @sunday = @monday + 1.day, @monday + 2.days, @monday + 3.days, @monday + 4.days, @monday + 5.days, @monday + 6.days
    @monday_programme = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @monday, duration: @programme_duration)
    @tuesday_programme = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @tuesday, duration: @programme_duration)
    @wednesday_programme = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @wednesday, duration: @programme_duration)
    @thursday_programme = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @thursday, duration: @programme_duration)
    @friday_programme = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @friday, duration: @programme_duration)
    @saturday_programme = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @saturday, duration: @programme_duration)
    @sunday_programme = SimplePvr::Model::Programme.create(title: @programme_title, channel: @dr_1, start_time: @sunday, duration: @programme_duration)

    SimplePvr::Model::Schedule.create(type: :specification, title: @programme_title, filter_by_weekday: true, monday: false, tuesday: true, wednesday: true, thursday: false, friday: false, saturday: true, sunday: true)

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, @programme_title, @tuesday - 2.minutes, 67.minutes, @tuesday_programme),
      SimplePvr::Model::Recording.new(@dr_1, @programme_title, @wednesday - 2.minutes, 67.minutes, @wednesday_programme),
      SimplePvr::Model::Recording.new(@dr_1, @programme_title, @saturday - 2.minutes, 67.minutes, @saturday_programme),
      SimplePvr::Model::Recording.new(@dr_1, @programme_title, @sunday - 2.minutes, 67.minutes, @sunday_programme),
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