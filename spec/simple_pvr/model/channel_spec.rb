require 'simple_pvr'

describe SimplePvr::Model::Channel do
  include SimplePvr::Model
  
  before :all do
    SimplePvr::Model::DatabaseInitializer.prepare_for_test
  end
  
  before :each do
    SimplePvr::Model::DatabaseInitializer.clear
  end
  
  it 'can insert channels' do
    3.times {|i| SimplePvr::Model::Channel.add("Channel #{i}", 23000000, 1098) }

    SimplePvr::Model::Channel.all.length.should == 3
  end

  it 'can clear channels' do
    3.times {|i| Channel.add("Channel #{i}", 23000000, 1098) }
    Channel.clear
  
    Channel.all.length.should == 0
  end

  it 'clears all programmes when clearing channels' do
    channel = Channel.add("DR 1", 23000000, 1098)
    3.times { Programme.add(channel, 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes) }
    Channel.clear

    Programme.all.length.should == 0
  end
  
  it 'can find channels' do
    Channel.add('Known channel', 23000000, 1098)
    
    channel = Channel.with_name('Known channel')
    channel.name.should == 'Known channel'
    channel.frequency.should == 23000000
    channel.channel_id.should == 1098
  end

  it 'complains when asked for non-existing channel' do
    expect { Channel.with_name('unknown') }.to raise_error "Unknown channel: 'unknown'"
  end
  
  it 'can fetch all channels alphabetically' do
    Channel.add('Channel 2', 23000000, 1098)
    Channel.add('Channel 1', 23000000, 1098)
    Channel.add('Channel 3', 23000000, 1098)
    
    channels = Channel.sorted_by_name
    channels.length.should == 3
    channels[0].name.should == 'Channel 1'
    channels[1].name.should == 'Channel 2'
    channels[2].name.should == 'Channel 3'
  end
end