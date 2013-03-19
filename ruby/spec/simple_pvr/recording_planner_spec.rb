require 'simple_pvr'

describe SimplePvr::RecordingPlanner do
  before do
    SimplePvr::Model::DatabaseInitializer.prepare_for_test
    SimplePvr::Model::DatabaseInitializer.clear
    @dr_1 = SimplePvr::Model::Channel.create(name: 'DR 1')
    @dr_k = SimplePvr::Model::Channel.create(name: 'DR K')
    @start_time_1, @start_time_2 = Time.local(2012, 7, 10, 20, 50), Time.local(2012, 7, 17, 20, 50)
    @old_start_time = Time.local(2012, 8, 10, 20, 50)
    @programme_duration = 60.minutes.to_i
    
    @scheduler = double('Scheduler')
    SimplePvr::PvrInitializer.stub(scheduler: @scheduler)

    Time.stub!(now: Time.local(2012, 7, 9, 20, 50))
  end

  it 'cleans up outdated schedules' do
    SimplePvr::Model::Schedule.should_receive(:cleanup)
    @scheduler.should_receive(:recordings=).with([])

    SimplePvr::RecordingPlanner.reload
  end
  
  it 'resets the recordings when no schedules exist' do
    SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_k, start_time: @start_time_1, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: 'Borgias' + "-", channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([])
    
    SimplePvr::RecordingPlanner.reload
  end
  
  it 'can set up schedules from channel and programme title' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', channel: @dr_k)
    @programme_1 = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_k, start_time: @start_time_1, duration: @programme_duration)
    @programme_2 = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: 'Irrelevant programme', channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes, @programme_1),
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_2)
    ])

    SimplePvr::RecordingPlanner.reload
  end

  it 'takes the start early and end late minutes from schedule' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', channel: @dr_k, custom_start_early_minutes: 4, custom_end_late_minutes: 10)
    @programme_1 = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_k, start_time: @start_time_1, duration: @programme_duration)
    
    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 10, 20, 46), 74.minutes, @programme_1),
    ])

    SimplePvr::RecordingPlanner.reload
  end

  it 'can set up schedules from channel, programme title, and start time' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', channel: @dr_k, start_time: @start_time_2)
    SimplePvr::Model::Programme.create(title: 'Borgias', channel:@dr_k, start_time: @start_time_1, duration: @programme_duration)
    @programme_to_be_recorded = SimplePvr::Model::Programme.create(title: 'Borgias', channel:@dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([
         SimplePvr::Model::Recording.new(@dr_k, 'Borgias', @start_time_2.advance(minutes: -2), 2.minutes + @programme_duration + 5.minutes, @programme_to_be_recorded)
    ])

    SimplePvr::RecordingPlanner.reload
  end

  it 'can set up schedules from programme title only' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias')
    @programme_1 = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @start_time_1, duration: @programme_duration)
    @programme_2 = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)
    SimplePvr::Model::Programme.create(title: 'Irrelevant programme', channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', Time.local(2012, 7, 10, 20, 48), 67.minutes, @programme_1),
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_2)
    ])

    SimplePvr::RecordingPlanner.reload
  end
  
  it 'can set up schedules for specific days of the week' do
    @monday = Time.local(2012, 12, 10, 20, 50)
    @tuesday, @wednesday, @thursday, @friday, @saturday, @sunday = @monday + 1.day, @monday + 2.days, @monday + 3.days, @monday + 4.days, @monday + 5.days, @monday + 6.days
    @monday_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @monday, duration: @programme_duration)
    @tuesday_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @tuesday, duration: @programme_duration)
    @wednesday_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @wednesday, duration: @programme_duration)
    @thursday_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @thursday, duration: @programme_duration)
    @friday_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @friday, duration: @programme_duration)
    @saturday_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @saturday, duration: @programme_duration)
    @sunday_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @sunday, duration: @programme_duration)

    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', filter_by_weekday: true, monday: false, tuesday: true, wednesday: true, thursday: false, friday: false, saturday: true, sunday: true)

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @tuesday - 2.minutes, 67.minutes, @tuesday_programme),
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @wednesday - 2.minutes, 67.minutes, @wednesday_programme),
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @saturday - 2.minutes, 67.minutes, @saturday_programme),
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @sunday - 2.minutes, 67.minutes, @sunday_programme),
    ])
    
    SimplePvr::RecordingPlanner.reload
  end

  it 'can set up schedules for programmes starting before specific time of day' do
    @early_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 9, 30), duration: @programme_duration)
    @late_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 17, 0), duration: @programme_duration)
    @too_late_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 17, 01), duration: @programme_duration)

    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', filter_by_time_of_day: true, to_time_of_day: '17:00')

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @early_programme.start_time - 2.minutes, 67.minutes, @early_programme),
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @late_programme.start_time - 2.minutes, 67.minutes, @late_programme)
    ])

    SimplePvr::RecordingPlanner.reload
  end

  it 'can set up schedules for programmes starting after a specific time of day' do
    @too_early_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 16, 59), duration: @programme_duration)
    @early_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 17, 0), duration: @programme_duration)
    @late_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 19, 30), duration: @programme_duration)

    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', filter_by_time_of_day: true, from_time_of_day: '17:00')

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @early_programme.start_time - 2.minutes, 67.minutes, @early_programme),
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @late_programme.start_time - 2.minutes, 67.minutes, @late_programme)
    ])

    SimplePvr::RecordingPlanner.reload
  end

  it 'can set up schedules for programmes starting in certain interval during day' do
    @too_early_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 16, 59), duration: @programme_duration)
    @early_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 17, 0), duration: @programme_duration)
    @late_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 19, 0), duration: @programme_duration)
    @too_late_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 19, 1), duration: @programme_duration)

    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', filter_by_time_of_day: true, from_time_of_day: '17:00', to_time_of_day: '19:00')

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @early_programme.start_time - 2.minutes, 67.minutes, @early_programme),
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @late_programme.start_time - 2.minutes, 67.minutes, @late_programme)
    ])

    SimplePvr::RecordingPlanner.reload
  end

  it 'can set up schedules for programmes starting in certain intervals during day, stretching across midnight' do
    @too_early_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 16, 59), duration: @programme_duration)
    @early_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 12, 17, 0), duration: @programme_duration)
    @late_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 13, 5, 0), duration: @programme_duration)
    @too_late_programme = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: Time.local(2012, 12, 13, 5, 1), duration: @programme_duration)

    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias', filter_by_time_of_day: true, from_time_of_day: '17:00', to_time_of_day: '5:00')

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @early_programme.start_time - 2.minutes, 67.minutes, @early_programme),
      SimplePvr::Model::Recording.new(@dr_1, 'Borgias', @late_programme.start_time - 2.minutes, 67.minutes, @late_programme)
    ])

    SimplePvr::RecordingPlanner.reload
  end

  it 'ignores programmes for which exceptions exist' do
    SimplePvr::Model::Schedule.create(type: :specification, title: 'Borgias')
    SimplePvr::Model::Schedule.create(type: :exception, title: 'Borgias', channel: @dr_1, start_time: @start_time_1)
    SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_1, start_time: @start_time_1, duration: @programme_duration)
    @programme_to_be_recorded = SimplePvr::Model::Programme.create(title: 'Borgias', channel: @dr_k, start_time: @start_time_2, duration: @programme_duration)

    @scheduler.should_receive(:recordings=).with([
      SimplePvr::Model::Recording.new(@dr_k, 'Borgias', Time.local(2012, 7, 17, 20, 48), 67.minutes, @programme_to_be_recorded)
    ])

    SimplePvr::RecordingPlanner.reload
  end
end