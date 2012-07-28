require 'simple_pvr/model/database_initializer'

describe SimplePvr::Model::Programme do
  include SimplePvr::Model
  
  before :all do
    DatabaseInitializer.prepare_for_test
  end
  
  before :each do
    DatabaseInitializer.clear
  end

  before do
    @dr_1 = Channel.add('DR 1', 23000000, 1098)
    @dr_2 = Channel.add('DR 2', 24000000, 1099)
  end
  
  it 'can insert programmes' do
    3.times { Programme.add('DR 1', 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes) }
  
    Programme.all.length.should == 3
  end
  
  it 'cannot insert programmes for unknown channels' do
    expect {
      Programme.add('Unknown', 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes)
    }.to raise_error 'Unknown channel: Unknown'
  end

  it 'can clear all programmes' do
    3.times { Programme.add('DR 1', 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes) }
    Programme.clear
  
    Programme.all.length.should == 0
  end

  it 'can find all programmes with a certain title' do
    Programme.add('DR 2', 'Interesting', 'Second', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
    Programme.add('DR 1', 'Interesting', 'First', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes)
    Programme.add('DR 1', 'Uninteresting', 'Subtitle', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)

    programmes = Programme.with_title('Interesting')
    programmes.length.should == 2

    programmes[0].channel.should == @dr_1
    programmes[0].title.should == 'Interesting'
    programmes[0].subtitle.should == 'First'
    programmes[0].description.should == 'Description'
    programmes[0].start_time.should == Time.local(2012, 7, 17, 20, 30)
    programmes[0].duration.should == 50.minutes

    programmes[1].channel.should == @dr_2
    programmes[1].title.should == 'Interesting'
    programmes[1].subtitle.should == 'Second'
  end

  it 'can find all programmes with a certain title for a specific channel' do
    Programme.add('DR 1', 'Interesting', 'Second', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
    Programme.add('DR 1', 'Interesting', 'First', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes)
    Programme.add('DR 2', 'Interesting', '...but on wrong channel...', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
    Programme.add('DR 1', 'Uninteresting', 'Subtitle', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
  
    programmes = Programme.on_channel_with_title(@dr_1, 'Interesting')
    programmes.length.should == 2

    programmes[0].channel.should == @dr_1
    programmes[0].title.should == 'Interesting'
    programmes[0].subtitle.should == 'First'

    programmes[1].channel.should == @dr_1
    programmes[1].title.should == 'Interesting'
    programmes[1].subtitle.should == 'Second'
  end
end