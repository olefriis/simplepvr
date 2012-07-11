require 'rspec'
require File.dirname(__FILE__) + '/../lib/device_finder'

describe DeviceFinder do
  before do
    @pipe = double('pipe')
    IO.should_receive(:popen).with('hdhomerun_config discover').and_yield(@pipe)
  end
  
  it 'can find a device when present' do
    @pipe.stub(:read).and_return('hdhomerun device 12106FA4 found at 10.0.0.4')

    DeviceFinder.find.should == '12106FA4'
  end
  
  it 'raises an exception when no device is present' do
    @pipe.stub(:read).and_return('no devices found')

    expect { DeviceFinder.find }.to raise_error(Exception, 'No device found: no devices found')
  end
end