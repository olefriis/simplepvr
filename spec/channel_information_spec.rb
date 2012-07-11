require 'rspec'
require File.dirname(__FILE__) + '/../lib/channel_information'

describe ChannelInformation do
  before do
    @channel_information = ChannelInformation.new(File.dirname(__FILE__) + '/resources/channels.txt')
  end
  
  it 'knows the frequency and channel ID of the channels in the file read' do
    known_channel = @channel_information.information_for('DR K')
    known_channel[0].should == 282000000
    known_channel[1].should == 1098
  end
  
  it 'complains when asking for non-existing channel' do
    expect { @channel_information.information_for('unknown') }.to raise_error 'Unknown channel: unknown'
  end
end