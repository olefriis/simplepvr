require 'simple_pvr'

describe SimplePvr::Model::Schedule do
  Channel, Schedule = SimplePvr::Model::Channel, SimplePvr::Model::Schedule
  
  before :all do
    SimplePvr::Model::DatabaseInitializer.prepare_for_test
  end
  
  before :each do
    SimplePvr::Model::DatabaseInitializer.clear
    @dr_1 = Channel.add('DR 1', 23000000, 1098)
  end
  
  it 'can save a schedule with a title' do
    Schedule.add_specification(title: 'Sports')
    
    schedules = Schedule.all
    schedules.length.should == 1
    schedules[0].type.should == :specification
    schedules[0].title.should == 'Sports'
    schedules[0].channel.should be_nil
  end
  
  it 'can save a schedule with a title and a channel' do
    Schedule.add_specification(title: 'Sports', channel: @dr_1)
    
    schedules = Schedule.all
    schedules.length.should == 1
    schedules[0].type.should == :specification
    schedules[0].title.should == 'Sports'
    schedules[0].channel.name.should == 'DR 1'
  end

  it 'can save a schedule with a title and a channel and a start_time' do
    start_time = Time.local(2012, 7, 10, 20, 50)
    Schedule.add_specification(title: 'Sports', channel: @dr_1, start_time: start_time)

    schedules = Schedule.all
    schedules.length.should == 1
    schedules[0].type.should == :specification
    schedules[0].title.should == 'Sports'
    schedules[0].channel.name.should == 'DR 1'
    schedules[0].start_time.should == start_time
  end

  it 'starts 2 minutes early and 5 minutes late by default' do
    schedule = Schedule.new

    schedule.custom_start_early_minutes.should be_nil
    schedule.custom_end_late_minutes.should be_nil
    schedule.start_early_minutes.should == 2
    schedule.end_late_minutes.should == 5
  end

  it 'can have custom start early and end late intervals' do
    schedule = Schedule.new(custom_start_early_minutes: 5, custom_end_late_minutes: 10)

    schedule.custom_start_early_minutes.should == 5
    schedule.custom_end_late_minutes.should == 10
    schedule.start_early_minutes.should == 5
    schedule.end_late_minutes.should == 10
  end

  it 'can clean up schedules that are out of date' do
    Schedule.add_specification(title: 'Old Sports News', start_time: 60.minutes.ago, end_time: 10.minutes.ago)
    Schedule.add_specification(title: 'Current Sports News', start_time: 5.minutes.ago, end_time: 10.minutes.from_now)
    Schedule.add_specification(title: 'Upcoming Sports News', start_time: 1.hour.from_now, end_time: 2.hours.from_now)
    Schedule.add_specification(title: 'Great movies')

    Schedule.cleanup
    remaining_names = Schedule.all.collect {|s| s.title }
    remaining_names.should include('Current Sports News')
    remaining_names.should include('Upcoming Sports News')
    remaining_names.should include('Great movies')
    remaining_names.should_not include('Old Sports News')
  end
end