require 'rspec'
require File.dirname(__FILE__) + '/../lib/simplepvr'

describe 'SimplePVR' do
  before do
    @scheduler = double('Scheduler')
    Scheduler.should_receive(:new).and_return(@scheduler)
  end
  
  it 'initializes the system' do
    PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:run!)
    
    schedule {}
  end
  
  it 'sets up schedules' do
    PvrInitializer.should_receive(:setup)
    @scheduler.should_receive(:add).with('DR K', 'Borgias', 'Tue Jul 10 20:46:00 +0200 2012', 60.minutes)
    @scheduler.should_receive(:add).with('TV 2', 'Sports news', 'Wed Jul 11 12:15:00 +0200 2012', 20.minutes)
    @scheduler.should_receive(:run!)
    
    schedule do
      record 'DR K', 'Borgias', 'Tue Jul 10 20:46:00 +0200 2012', 60.minutes
      record 'TV 2', 'Sports news', 'Wed Jul 11 12:15:00 +0200 2012', 20.minutes
    end
  end
end