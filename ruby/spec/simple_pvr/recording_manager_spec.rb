require 'simple_pvr'
require 'yaml'

describe SimplePvr::RecordingManager do
  before do
    @recording_dir = File.dirname(__FILE__) + '/../resources/recordings'
    FileUtils.rm_rf(@recording_dir) if Dir.exists?(@recording_dir)
    FileUtils.mkdir_p(@recording_dir + "/series 1/1")
    FileUtils.mkdir_p(@recording_dir + "/series 1/3")
    FileUtils.mkdir_p(@recording_dir + "/Another series/10")
    
    @manager = SimplePvr::RecordingManager.new(@recording_dir)
  end
  
  it 'knows which shows are recorded' do
    @manager.shows.should == ['Another series', 'series 1']
  end
  
  it 'can delete all episodes of a given show' do
    @manager.delete_show('series 1')
    File.exists?(@recording_dir + '/series 1').should be_false
  end
  
  it 'knows which episodes of a given show exists' do
    episodes = @manager.episodes_of('series 1')
    
    episodes.length.should == 2
    episodes[0].episode.should == '1'
    episodes[1].episode.should == '3'
  end
  
  it 'reads metadata for recordings if present' do
    start_time = Time.now
    metadata = {
      channel: 'Channel 4',
      subtitle: 'A subtitle',
      description: 'A description',
      start_time: start_time,
      duration: 10.minutes
    }
    File.open(@recording_dir + '/series 1/3/metadata.yml', 'w') {|f| f.write(metadata.to_yaml) }
    
    episodes = @manager.episodes_of('series 1')
    
    episodes.length.should == 2

    episodes[0].show_name.should == 'series 1'
    episodes[0].episode.should == '1'
    
    episodes[1].show_name.should == 'series 1'
    episodes[1].episode.should == '3'
    episodes[1].channel.should == 'Channel 4'
    episodes[1].subtitle.should == 'A subtitle'
    episodes[1].description.should == 'A description'
    episodes[1].start_time.should == start_time
    episodes[1].duration == 10.minutes
  end
  
  it 'knows when no thumbnail exists' do
    episodes = @manager.episodes_of('series 1')

    episodes[0].has_thumbnail.should == false
  end

  it 'knows when thumbnail exists' do
    FileUtils.touch(@recording_dir + "/series 1/1/thumbnail.png")
    episodes = @manager.episodes_of('series 1')

    episodes[0].has_thumbnail.should == true
  end

  it 'knows when no webm file exists' do
    episodes = @manager.episodes_of('series 1')

    episodes[0].has_webm.should == false
  end

  it 'knows when a webm file exists' do
    FileUtils.touch(@recording_dir + "/series 1/1/stream.webm")
    episodes = @manager.episodes_of('series 1')

    episodes[0].has_webm.should == true
  end

  it 'can delete an episode of a given show' do
    @manager.delete_show_episode('series 1', '3')
    File.exists?(@recording_dir + '/series 1/3').should be_false
  end
  
  context 'when creating recording directories' do
    before do
      @start_time = Time.local(2012, 7, 23, 15, 30, 15)
      @recording = SimplePvr::Model::Recording.new(double(name: 'Channel 4'), 'Star Trek', @start_time, 50.minutes)
    end
    
    it 'records to directory with number 1 if nothing exists' do
      @manager.create_directory_for_recording(@recording)
    
      File.exists?(@recording_dir + '/Star Trek/1').should be_true
    end
    
    it 'removes some potentially harmful characters from directory name' do
      @recording.show_name = "Some... harmful/irritating\\ characters in: '*title\""
      @manager.create_directory_for_recording(@recording)
    
      File.exists?(@recording_dir + '/Some harmfulirritating characters in title/1').should be_true
    end
  
    it 'finds a directory name for titles which would otherwise get an empty directory name' do
      @recording.show_name = '/.'
      @manager.create_directory_for_recording(@recording)
    
      File.exists?(@recording_dir + '/Unnamed/1').should be_true
    end
  
    it 'finds next number in sequence for new directory' do
      FileUtils.mkdir_p(@recording_dir + "/Star Trek/1")
      FileUtils.mkdir_p(@recording_dir + "/Star Trek/2")
      FileUtils.mkdir_p(@recording_dir + "/Star Trek/3")
      @manager.create_directory_for_recording(@recording)
    
      File.exists?(@recording_dir + '/Star Trek/4').should be_true
    end
  
    it 'ignores random directories which are not sequence numbers' do
      FileUtils.mkdir_p(@recording_dir + "/Star Trek/4")
      FileUtils.mkdir_p(@recording_dir + "/Star Trek/random directory name")
      @manager.create_directory_for_recording(@recording)
    
      File.exists?(@recording_dir + '/Star Trek/5').should be_true
    end
    
    it 'stores simple metadata if no programme information exists' do
      @manager.create_directory_for_recording(@recording)
    
      metadata = YAML.load_file(@recording_dir + '/Star Trek/1/metadata.yml')
      metadata[:title].should == 'Star Trek'
      metadata[:channel].should == 'Channel 4'
      metadata[:start_time].should == @start_time
      metadata[:duration].should == 50.minutes
    end
    
    it 'stores extensive metadata if programme information exists' do
      start_time = Time.local(2012, 7, 23, 15, 30, 15)
      recording = SimplePvr::Model::Recording.new(double(name: 'Channel 4'), 'Extensive Metadata', start_time, 50.minutes)
      recording.programme = SimplePvr::Model::Programme.new(subtitle: 'A subtitle', description: "A description,\nspanning several lines")
      @manager.create_directory_for_recording(recording)
    
      metadata = YAML.load_file(@recording_dir + '/Extensive Metadata/1/metadata.yml')
      metadata[:title].should == 'Extensive Metadata'
      metadata[:channel].should == 'Channel 4'
      metadata[:start_time].should == start_time
      metadata[:duration].should == 50.minutes
      metadata[:subtitle].should == 'A subtitle'
      metadata[:description].should == "A description,\nspanning several lines"
    end
  end
end