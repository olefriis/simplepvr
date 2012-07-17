require 'simple_pvr/pvr_initializer'

describe SimplePvr::PvrInitializer do
  it 'runs a channel scan if channels.txt is missing' do
    File.should_receive(:exists?).with('channels.txt').and_return(false)
    hd_home_run = double('HDHomeRun')
    hd_home_run.should_receive(:scan_for_channels)
    SimplePvr::HDHomeRun.stub(:new => hd_home_run)
    
    SimplePvr::PvrInitializer.setup
  end
  
  it 'does nothing if channels.txt is present' do
    File.should_receive(:exists?).with('channels.txt').and_return(true)

    SimplePvr::PvrInitializer.setup
  end
end