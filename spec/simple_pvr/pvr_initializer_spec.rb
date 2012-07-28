require 'simple_pvr/pvr_initializer'

describe SimplePvr::PvrInitializer do
  before do
    @dao = double('Dao')
    SimplePvr::Dao.stub(:new => @dao)
    
    @scheduler = double('Scheduler')
    SimplePvr::Scheduler.stub(new: @scheduler)
    
    @hd_home_run = double('HDHomeRun')
    SimplePvr::HDHomeRun.stub(:new).with(@dao).and_return(@hd_home_run)
  end
  
  it 'starts the scheduler' do
    @dao.stub(:number_of_channels => 5)
    @scheduler.should_receive(:start)

    SimplePvr::PvrInitializer.setup
  end
  
  context 'when scheduler is started' do
    before do
      @scheduler.stub(:start)
    end
  
    it 'runs a channel scan if channels are missing' do
      @dao.stub(:number_of_channels => 0)
      @hd_home_run.should_receive(:scan_for_channels)
    
      SimplePvr::PvrInitializer.setup
    end
  
    it 'does nothing if channels.txt is present' do
      @dao.stub(:number_of_channels => 1)

      SimplePvr::PvrInitializer.setup
    end
  
    it 'initializes a DAO and HDHomeRun instance' do
      @dao.stub(:number_of_channels => 1)
    
      SimplePvr::PvrInitializer.setup
      SimplePvr::PvrInitializer.dao.should == @dao
      SimplePvr::PvrInitializer.hd_home_run.should == @hd_home_run
    end
  end
end