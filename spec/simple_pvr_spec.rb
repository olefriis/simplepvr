require 'simple_pvr'

describe 'SimplePvr' do
  before do
    @scheduler = double('Scheduler')
    Scheduler.stub(:new => @scheduler)
  end
  
  it 'initializes the system' do
    PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:run!)
    
    schedule {}
  end
  
  it 'sets up schedules' do
    PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:add).with('Borgias', from:'DR K', at:'Tue Jul 10 20:46:00 +0200 2012', for:60.minutes)
    @scheduler.should_receive(:add).with('Sports news', from:'TV 2', at:'Wed Jul 11 12:15:00 +0200 2012', for:20.minutes)
    @scheduler.should_receive(:run!)
    
    schedule do
      record 'Borgias', from:'DR K', at:'Tue Jul 10 20:46:00 +0200 2012', for:60.minutes
      record 'Sports news', from:'TV 2', at:'Wed Jul 11 12:15:00 +0200 2012', for:20.minutes
    end
  end
end