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
    Schedule.add_specification(:title => 'Sports')
    
    schedules = Schedule.all
    schedules.length.should == 1
    schedules[0].type.should == :specification
    schedules[0].title.should == 'Sports'
    schedules[0].channel.should be_nil
  end
  
  it 'can save a schedule with a title and a channel' do
    Schedule.add_specification(:title => 'Sports', :channel => @dr_1)
    
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
end