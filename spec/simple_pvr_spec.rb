require 'simple_pvr'

describe 'SimplePvr' do
  MockProgrammeForSimplePvr = Struct.new(:channel, :start_time, :duration)
  MockChannelForSimplePvr = Struct.new(:name)
  
  before do
    @scheduler = double('Scheduler')
    SimplePvr::Scheduler.stub(:new => @scheduler)
    
    @dao = double('Dao')
    SimplePvr::PvrInitializer.stub(:dao => @dao)
    SimplePvr::PvrInitializer.stub(:setup)
  end
  
  it 'initializes the system' do
    SimplePvr::PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:run!)
    
    schedule {}
  end
  
  it 'can set up simple schedules' do
    SimplePvr::PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:Time.local(2012, 7, 10, 20, 46), for:60.minutes)
    @scheduler.should_receive(:add).with('Sports news', from:'TV 2', at:Time.local(2012, 7, 11, 12, 15), for:20.minutes)
    @scheduler.should_receive(:run!)
    
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
    @dao.stub(:programmes_on_channel_with_title).with('DR K', 'Borgias').and_return([
      MockProgrammeForSimplePvr.new(MockChannelForSimplePvr.new('DR K'), Time.local(2012, 7, 10, 20, 50), 60.minutes),
      MockProgrammeForSimplePvr.new(MockChannelForSimplePvr.new('DR K'), Time.local(2012, 7, 17, 20, 50), 60.minutes)
    ])
    
    SimplePvr::PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:Time.local(2012, 7, 10, 20, 50) - 2.minutes, for:67.minutes)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:Time.local(2012, 7, 17, 20, 50) - 2.minutes, for:67.minutes)
    @scheduler.should_receive(:run!)

    schedule do
      record 'Borgias', from:'DR K'
    end
  end
  
  it 'can set up schedules from program title only' do
    @dao.stub(:programmes_with_title).with('Borgias').and_return([
      MockProgrammeForSimplePvr.new(MockChannelForSimplePvr.new('DR 1'), Time.local(2012, 7, 10, 20, 50), 60.minutes),
      MockProgrammeForSimplePvr.new(MockChannelForSimplePvr.new('DR K'), Time.local(2012, 7, 17, 20, 50), 60.minutes)
    ])
    
    SimplePvr::PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:add).with('Borgias', from:'DR 1', at:Time.local(2012, 7, 10, 20, 48), for:67.minutes)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:Time.local(2012, 7, 17, 20, 48), for:67.minutes)
    @scheduler.should_receive(:run!)

    schedule do
      record 'Borgias'
    end
  end
end