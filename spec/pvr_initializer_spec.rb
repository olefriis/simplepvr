require 'rspec'
require File.dirname(__FILE__) + '/../lib/pvr_initializer'

describe PvrInitializer do
  it 'runs a channel scan if channels.txt is missing' do
    File.should_receive(:exists?).with('channels.txt').and_return(false)
    DeviceFinder.should_receive(:find).and_return('ABCDEF01')
    PvrInitializer.should_receive(:system).with('hdhomerun_config ABCDEF01 scan /tuner0 channels.txt')
    
    PvrInitializer.setup
  end
  
  it 'does nothing if channels.txt is present' do
    File.should_receive(:exists?).with('channels.txt').and_return(true)

    PvrInitializer.setup
  end
end