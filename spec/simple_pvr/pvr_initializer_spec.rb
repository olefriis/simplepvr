require 'simple_pvr/pvr_initializer'

describe SimplePvr::PvrInitializer do
  before do
    @dao = double('Dao')
    SimplePvr::Dao.stub(:new => @dao)
    
    @hd_home_run = double('HDHomeRun')
    SimplePvr::HDHomeRun.stub(:new).with(@dao).and_return(@hd_home_run)
  end
  
  it 'runs a channel scan if channels.txt is missing' do
    File.should_receive(:exists?).with('channels.txt').and_return(false)
    @hd_home_run.should_receive(:scan_for_channels)
    
    SimplePvr::PvrInitializer.setup
  end
  
  it 'does nothing if channels.txt is present' do
    File.should_receive(:exists?).with('channels.txt').and_return(true)

    SimplePvr::PvrInitializer.setup
  end
  
  it 'initializes a DAO and HDHomeRun instance' do
    File.stub(:exists?).with('channels.txt').and_return(true)
    
    SimplePvr::PvrInitializer.setup
    SimplePvr::PvrInitializer.dao.should == @dao
    SimplePvr::PvrInitializer.hd_home_run.should == @hd_home_run
  end
end