require 'simple_pvr'

describe 'SimplePvr' do
  before do
    @scheduler = double('Scheduler')
    SimplePvr::Scheduler.stub(:new => @scheduler)
    
    @dao = double('Dao')
    SimplePvr::Dao.stub(:new => @dao)
  end
  
  it 'initializes the system' do
    SimplePvr::PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:run!)
    
    schedule {}
  end
  
  it 'can set up simple schedules' do
    SimplePvr::PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:'Jul 10 2012 20:46:00', for:60.minutes)
    @scheduler.should_receive(:add).with('Sports news', from:'TV 2', at:'Jul 11 2012 12:15:00', for:20.minutes)
    @scheduler.should_receive(:run!)
    
    schedule do
      record 'Borgias', from:'DR K', at:'Jul 10 2012 20:46:00', for:60.minutes
      record 'Sports news', from:'TV 2', at:'Jul 11 2012 12:15:00', for:20.minutes
    end
  end
  
  it 'can set up schedules from channel and program title' do
    MockProgramme = Struct.new(:start_time, :duration)
    @dao.stub(:programmes_on_channel_with_title).with('DR K', 'Borgias').and_return([
      MockProgramme.new(Time.local(2012, 7, 10, 20, 50), 60.minutes),
      MockProgramme.new(Time.local(2012, 7, 17, 20, 50), 60.minutes)
    ])
    
    SimplePvr::PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:Time.local(2012, 7, 10, 20, 50) - 2.minutes, for:67.minutes)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:Time.local(2012, 7, 17, 20, 50) - 2.minutes, for:67.minutes)
    @scheduler.should_receive(:add).with('Sports news', from:'TV 2', at:'Jul 11 2012 12:15:00', for:20.minutes)
    @scheduler.should_receive(:run!)

    schedule do
      record 'Borgias', from:'DR K'
      record 'Sports news', from:'TV 2', at:'Jul 11 2012 12:15:00', for:20.minutes
    end
  end
end