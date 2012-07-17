require 'simple_pvr/scheduler'

describe Scheduler do
  before do
    @channel_information = double('ChannelInformation')
    @channel_information.stub(:information_for).with('DR K').and_return([282000000, 1098])
    ChannelInformation.stub(:new => @channel_information)

    Time.stub(:now => Time.local(2012, 7, 14, 19, 30))
    
    @rufus_scheduler = double('RufusScheduler')
    Rufus::Scheduler.stub(:start_new => @rufus_scheduler)
  end
  
  it 'starts a new Rufus scheduler and waits' do
    @rufus_scheduler.should_receive(:join)
    
    scheduler = Scheduler.new
    scheduler.run!
  end
  
  it 'will create schedules with recordings of correct duration' do
    start_time = Time.local(2012, 7, 15, 20, 15, 30) # Jul 15, 2012, 20:15:30
    
    @rufus_scheduler.should_receive(:at).with(start_time).and_yield
    Recorder.should_receive(:new).with('Borgia', 282000000, 1098).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)
    @recorder.should_receive(:stop!)
    @rufus_scheduler.should_receive(:join)
    
    scheduler = Scheduler.new
    scheduler.should_receive(:sleep).with(60.minutes)
    scheduler.add('Borgia', from:'DR K', at:'Jul 15 2012 20:15:30', for:60.minutes)
    scheduler.run!
  end
  
  it 'skips recordings that have passed' do
    @rufus_scheduler.should_receive(:join)
    
    scheduler = Scheduler.new
    scheduler.add('Borgia', from:'DR K', at:'Jul 13 2012 20:15:30', for:60.minutes)
    scheduler.run!
  end
  
  it 'starts recordings that are in progress, and knows the proper end time' do
    start_time = Time.local(2012, 7, 14, 19, 15) # Jul 14, 2012, 19:15:00
    
    @rufus_scheduler.should_receive(:at).with(start_time).and_yield
    Recorder.should_receive(:new).with('Borgia', 282000000, 1098).and_return(@recorder = double('Recorder'))
    @recorder.should_receive(:start!)
    @recorder.should_receive(:stop!)
    @rufus_scheduler.should_receive(:join)
    
    scheduler = Scheduler.new
    scheduler.should_receive(:sleep).with(45.minutes)
    scheduler.add('Borgia', from:'DR K', at:'Jul 14 2012 19:15:00', for:60.minutes)
    scheduler.run!
  end
  
  it 'complains if given date with wrong syntax' do
    scheduler = Scheduler.new
    expect { scheduler.add('Borgia', from:'DR K', at:'invalid time', for:60.minutes) }.to raise_error "Invalid time 'invalid time'"
  end
  
  it 'complains if given unknown month' do
    scheduler = Scheduler.new
    expect { scheduler.add('Borgia', from:'DR K', at:'Abc 13 2012 20:15:30', for:60.minutes) }.to raise_error "Unknown month 'Abc'"
  end
end