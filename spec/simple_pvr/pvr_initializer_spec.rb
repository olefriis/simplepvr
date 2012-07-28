require 'simple_pvr/pvr_initializer'

describe SimplePvr::PvrInitializer do
  before do
    SimplePvr::Model::DatabaseInitializer.stub(:setup)
    
    @scheduler = double('Scheduler')
    SimplePvr::Scheduler.stub(new: @scheduler)
    
    @hdhomerun = double('HDHomeRun')
    SimplePvr::HDHomeRun.stub(new: @hdhomerun)
  end
  
  it 'starts the scheduler' do
    SimplePvr::Model::Channel.stub(all: [1, 2, 3, 4, 5])
    @scheduler.should_receive(:start)

    SimplePvr::PvrInitializer.setup
  end
  
  context 'when scheduler is started' do
    before do
      @scheduler.stub(:start)
    end
  
    it 'runs a channel scan if channels are missing' do
      SimplePvr::Model::Channel.stub(all: [])
      @hdhomerun.should_receive(:scan_for_channels)
    
      SimplePvr::PvrInitializer.setup
    end
  
    it 'does nothing if channels.txt is present' do
      SimplePvr::Model::Channel.stub(all: [1])

      SimplePvr::PvrInitializer.setup
    end
  
    it 'initializes a DAO and HDHomeRun instance' do
      SimplePvr::Model::Channel.stub(all: [1])
    
      SimplePvr::PvrInitializer.setup
      SimplePvr::PvrInitializer.dao.should == @dao
      SimplePvr::PvrInitializer.hdhomerun.should == @hdhomerun
    end
  end
end