require 'simple_pvr'

describe SimplePvr::Model::Channel do
  Channel, Programme = SimplePvr::Model::Channel, SimplePvr::Model::Programme
  
  before :all do
    SimplePvr::Model::DatabaseInitializer.prepare_for_test
  end
  
  before :each do
    SimplePvr::Model::DatabaseInitializer.clear
  end
  
  it 'can insert channels' do
    3.times {|i| Channel.add("Channel #{i}", 23000000, 1098) }

    Channel.all.length.should == 3
  end

  it 'can clear channels' do
    3.times {|i| Channel.add("Channel #{i}", 23000000, 1098) }
    Channel.clear
  
    Channel.all.length.should == 0
  end

  it 'clears all programmes when clearing channels' do
    channel = Channel.add("DR 1", 23000000, 1098)
    3.times { Programme.add(channel, 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes, nil) }
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
  
  it 'can fetch a channel along with the current and next 3 programmes' do
    channel = Channel.create(name: 'Channel 1')

    now = Time.now
    ten_minutes = 10.minutes.to_i
    current = Programme.create(channel: channel, title: 'Current programme on channel 1', subtitle: 'Current programme subtitle', start_time: now.advance(minutes: -3), duration: ten_minutes)
    programme_2 = Programme.create(channel: channel, title: 'Next programme', subtitle: 'Next programme subtitle', start_time: now.advance(minutes: 7), duration: ten_minutes)
    programme_3 = Programme.create(channel: channel, title: 'Programme 3', start_time: now.advance(minutes: 17), duration: ten_minutes)
    programme_4 = Programme.create(channel: channel, title: 'Programme 4', start_time: now.advance(minutes: 27), duration: ten_minutes)

    channel_and_programmes = Channel.with_current_programmes(channel.id)

    channel_and_programmes[:channel].should == channel
    channel_and_programmes[:current_programme].should == current
    channel_and_programmes[:upcoming_programmes].should == [programme_2, programme_3, programme_4]
  end
  
  it 'does not fetch programmes for hidden channels' do
    channel = Channel.create(name: 'Channel 1')
    channel.hidden = true
    channel.save!

    now = Time.now
    ten_minutes = 10.minutes.to_i
    current = Programme.create(channel: channel, title: 'Current programme on channel 1', subtitle: 'Current programme subtitle', start_time: now.advance(minutes: -3), duration: ten_minutes)
    programme_2 = Programme.create(channel: channel, title: 'Next programme', subtitle: 'Next programme subtitle', start_time: now.advance(minutes: 7), duration: ten_minutes)

    channel_and_programmes = Channel.with_current_programmes(channel.id)

    channel_and_programmes[:channel].should == channel
    channel_and_programmes[:current_programme].should be_nil
    channel_and_programmes[:upcoming_programmes].should == []
  end

  it 'can fetch all channels, along with the current and next 3 programmes' do
    channel_1 = Channel.add('Channel 1', 23000000, 1098)
    channel_2 = Channel.add('Channel 2', 23000000, 1098)
    channel_3 = Channel.add('Channel 3', 23000000, 1098)
    
    now = Time.now
    ten_minutes = 10.minutes.to_i
    current_on_channel_1 = Programme.create(channel: channel_1, title: 'Current programme on channel 1', subtitle: 'Current programme subtitle', start_time: now.advance(minutes: -3), duration: ten_minutes)
    programme_2_on_channel_1 = Programme.create(channel: channel_1, title: 'Next programme', subtitle: 'Next programme subtitle', start_time: now.advance(minutes: 7), duration: ten_minutes)
    programme_3_on_channel_1 = Programme.create(channel: channel_1, title: 'Programme 3', start_time: now.advance(minutes: 17), duration: ten_minutes)
    programme_4_on_channel_1 = Programme.create(channel: channel_1, title: 'Programme 4', start_time: now.advance(minutes: 27), duration: ten_minutes)
    programme_5_on_channel_1 = Programme.create(channel: channel_1, title: 'Programme 5', start_time: now.advance(minutes: 37), duration: ten_minutes)

    programme_1_on_channel_2 = Programme.create(channel: channel_2, title: 'Next programme on channel 2', start_time: now.advance(minutes: 17), duration: ten_minutes)

    old_programme_on_channel_3 = Programme.create(channel: channel_2, title: 'Obsolete programme', start_time: now.advance(minutes: -20), duration: ten_minutes)

    channels = Channel.all_with_current_programmes
    channels.length.should == 3

    channels[0][:channel].should == channel_1
    channels[0][:current_programme].should == current_on_channel_1
    channels[0][:upcoming_programmes].should == [programme_2_on_channel_1, programme_3_on_channel_1, programme_4_on_channel_1]

    channels[1][:channel].should == channel_2
    channels[1][:current_programme].should be_nil
    channels[1][:upcoming_programmes].should == [programme_1_on_channel_2]

    channels[2][:channel].should == channel_3
    channels[2][:current_programme].should be_nil
    channels[2][:upcoming_programmes].should == []
  end
end