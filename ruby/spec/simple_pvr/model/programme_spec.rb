require 'simple_pvr'

describe SimplePvr::Model::Programme do
  Channel, Programme = SimplePvr::Model::Channel, SimplePvr::Model::Programme
  
  before :all do
    SimplePvr::Model::DatabaseInitializer.prepare_for_test
  end
  
  before :each do
    SimplePvr::Model::DatabaseInitializer.clear
  end

  before do
    @dr_1 = Channel.add('DR 1', 23000000, 1098)
    @dr_2 = Channel.add('DR 2', 24000000, 1099)
  end

  it 'knows its end time' do
    programme = Programme.new(start_time: Time.local(2012, 7, 17, 20, 30), duration: 50.minutes)

    programme.end_time.should == Time.local(2012, 7, 17, 21, 20)
  end

  it 'knows when it is outdated' do
    Programme.new(start_time: 10.minutes.ago, duration: 9.minutes).should be_outdated
    Programme.new(start_time: 10.minutes.ago, duration: 11.minutes).should_not be_outdated
  end
  
  it 'can insert programmes' do
    3.times { Programme.add(@dr_1, 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes, ' .4/12. ') }
  
    Programme.all.length.should == 3
  end

  it 'can clear all programmes' do
    3.times { Programme.add(@dr_1, 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes, nil) }
    Programme.clear
  
    Programme.all.length.should == 0
  end

  it 'can find all programmes with a certain title' do
    Programme.add(@dr_2, 'Interesting', 'Second', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    Programme.add(@dr_1, 'Interesting', 'First', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes, nil)
    Programme.add(@dr_1, 'Uninteresting', 'Subtitle', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)

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
    Programme.add(@dr_1, 'Interesting', 'Second', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    Programme.add(@dr_1, 'Interesting', 'First', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes, nil)
    Programme.add(@dr_2, 'Interesting', '...but on wrong channel...', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    Programme.add(@dr_1, 'Uninteresting', 'Subtitle', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
  
    programmes = Programme.on_channel_with_title(@dr_1, 'Interesting')
    programmes.length.should == 2

    programmes[0].channel.should == @dr_1
    programmes[0].title.should == 'Interesting'
    programmes[0].subtitle.should == 'First'

    programmes[1].channel.should == @dr_1
    programmes[1].title.should == 'Interesting'
    programmes[1].subtitle.should == 'Second'
  end
  
  it 'can find titles containing a certain string' do
    Programme.add(@dr_1, 'First programme', '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    Programme.add(@dr_2, 'Second programme', '', '', Time.local(2012, 7, 17, 20, 30), 50.minutes, nil)
    Programme.add(@dr_1, 'Uninteresting', '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    
    titles = Programme.titles_containing('programme')
    titles.should == ['First programme', 'Second programme']
  end
  
  it 'gives no duplicates as title search' do
    Programme.add(@dr_1, 'First programme', '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    Programme.add(@dr_1, 'First programme', '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    Programme.add(@dr_2, 'Second programme', '', '', Time.local(2012, 7, 17, 20, 30), 50.minutes, nil)
    
    titles = Programme.titles_containing('programme')
    titles.should == ['First programme', 'Second programme']
  end
  
  it 'finds at most 8 titles containing a certain string' do
    20.times {|i| Programme.add(@dr_1, "Programme #{i}", '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil) }

    titles = Programme.titles_containing('programme')
    titles.length.should == 8
  end
  
  it 'can find programmes with titles containing a certain string, ordered by start time' do
    first_programme = Programme.add(@dr_1, 'First programme', '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    second_programme = Programme.add(@dr_2, 'Second programme', '', '', Time.local(2012, 7, 17, 20, 30), 50.minutes, nil)
    Programme.add(@dr_1, 'Uninteresting', '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil)
    
    titles = Programme.with_title_containing('programme')
    titles.should == [second_programme, first_programme]
  end
  
  it 'finds at most 20 programmes with titles containing a certain string' do
    30.times {|i| Programme.add(@dr_1, "Programme #{i}", '', '', Time.local(2012, 7, 24, 20, 30), 50.minutes, nil) }

    titles = Programme.with_title_containing('programme')
    titles.length.should == 20
  end
end