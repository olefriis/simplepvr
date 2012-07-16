require 'rspec'
require File.dirname(__FILE__) + '/../lib/pvr_initializer'

describe PvrInitializer do
  it 'runs a channel scan if channels.txt is missing' do
    File.should_receive(:exists?).with('channels.txt').and_return(false)
    hd_home_run = double('HDHomeRun')
    hd_home_run.should_receive(:scan_for_channels)
    HDHomeRun.stub(:new => hd_home_run)
    
    PvrInitializer.setup
  end
  
  it 'does nothing if channels.txt is present' do
    File.should_receive(:exists?).with('channels.txt').and_return(true)

    PvrInitializer.setup
  end
end