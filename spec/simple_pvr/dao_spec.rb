require 'simple_pvr/dao'
require 'active_support/time_with_zone'
require 'active_support/core_ext/numeric/time' # So we can say 60.minutes

describe SimplePvr::Dao do
  before :all do
    @database_file_name = File.dirname(__FILE__) + '/../resources/test.sqlite'
    File.delete(@database_file_name) if File.exists?(@database_file_name)
  end
  
  before :each do
    @dao = SimplePvr::Dao.new(@database_file_name)
  end
  
  context 'when handling channels' do
    it 'can insert channels' do
      3.times {|i| @dao.add_channel("Channel #{i}", 23000000, 1098) }
    
      @dao.number_of_channels.should == 3
    end
  
    it 'can clear channels' do
      3.times {|i| @dao.add_channel("Channel #{i}", 23000000, 1098) }
      @dao.clear_channels
    
      @dao.number_of_channels.should == 0
    end
    
    it 'can find channels' do
      @dao.add_channel('Known channel', 23000000, 1098)
      
      channel = @dao.channel_with_name('Known channel')
      channel.name.should == 'Known channel'
      channel.frequency.should == 23000000
      channel.channel_id.should == 1098
    end

    it 'complains when asked for non-existing channel' do
      expect { @dao.channel_with_name('unknown') }.to raise_error 'Unknown channel: unknown'
    end
  end
  
  context 'when handling programmes' do
    before do
      @dao.add_channel('DR 1', 23000000, 1098)
      @dao.add_channel('DR 2', 24000000, 1099)
    end
    
    it 'can insert programmes' do
      3.times { @dao.add_programme('DR 1', 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes) }
    
      @dao.number_of_programmes.should == 3
    end
    
    it 'cannot insert programmes for unknown channels' do
      expect {
        @dao.add_programme('Unknown', 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes)
      }.to raise_error 'Unknown channel: Unknown'
    end

    it 'can clear all programmes' do
      3.times { @dao.add_programme('DR 1', 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes) }
      @dao.clear_programmes
    
      @dao.number_of_programmes.should == 0
    end
  
    it 'clears all programmes when clearing channels' do
      3.times { @dao.add_programme('DR 1', 'Title', 'Subtitle', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes) }
      @dao.clear_channels
  
      @dao.number_of_programmes.should == 0
    end
  
    it 'can find all programmes with a certain title' do
      @dao.clear_programmes

      @dao.add_programme('DR 2', 'Interesting', 'Second', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
      @dao.add_programme('DR 1', 'Interesting', 'First', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes)
      @dao.add_programme('DR 1', 'Uninteresting', 'Subtitle', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)

      programmes = @dao.programmes_with_title('Interesting')
      programmes.length.should == 2

      programmes[0].channel.name.should == 'DR 1'
      programmes[0].title.should == 'Interesting'
      programmes[0].subtitle.should == 'First'

      programmes[1].channel.name.should == 'DR 2'
      programmes[1].title.should == 'Interesting'
      programmes[1].subtitle.should == 'Second'
    end

    it 'can find all programmes with a certain title for a specific channel' do
      @dao.clear_programmes
    
      @dao.add_programme('DR 1', 'Interesting', 'Second', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
      @dao.add_programme('DR 1', 'Interesting', 'First', 'Description', Time.local(2012, 7, 17, 20, 30), 50.minutes)
      @dao.add_programme('DR 2', 'Interesting', '...but on wrong channel...', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
      @dao.add_programme('DR 1', 'Uninteresting', 'Subtitle', 'Description', Time.local(2012, 7, 24, 20, 30), 50.minutes)
    
      programmes = @dao.programmes_on_channel_with_title('DR 1', 'Interesting')
      programmes.length.should == 2

      programmes[0].channel.name.should == 'DR 1'
      programmes[0].title.should == 'Interesting'
      programmes[0].subtitle.should == 'First'

      programmes[1].channel.name.should == 'DR 1'
      programmes[1].title.should == 'Interesting'
      programmes[1].subtitle.should == 'Second'
    end
  end
end