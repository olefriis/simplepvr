require 'rspec'
require File.dirname(__FILE__) + '/../lib/scheduler'

describe Scheduler do
  before do
    ChannelInformation.should_receive(:new).and_return(@channel_information = double('ChannelInformation'))
    
    @rufus_scheduler = double('RufusScheduler')
  end
  
  it 'starts a new Rufus scheduler and waits' do
    Rufus::Scheduler.should_receive(:start_new).and_return(@rufus_scheduler)
    @rufus_scheduler.should_receive(:join)
    
    scheduler = Scheduler.new
    scheduler.run!
  end
  
  it 'will create schedules with recordings of correct duration' do
    Rufus::Scheduler.should_receive(:start_new).and_return(@rufus_scheduler)
    @channel_information.should_receive(:information_for).with('DR K').and_return([282000000, 1098])
    @rufus_scheduler.should_receive(:at).with('Tue Jul 10 20:46:00 +0200 2012').and_yield
    Recorder.should_receive(:new).with('Borgia', 282000000, 1098).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)
    @recorder.should_receive(:stop!)
    @rufus_scheduler.should_receive(:join)
    
    scheduler = Scheduler.new
    scheduler.should_receive(:sleep).with(60.minutes)
    scheduler.add('DR K', 'Borgia', 'Tue Jul 10 20:46:00 +0200 2012', 60.minutes)
    scheduler.run!
  end
end