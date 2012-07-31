require 'simple_pvr/recording_manager'

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
    @manager.episodes_of('series 1').should == ['1', '3']
  end
  
  it 'can delete an episode of a given show' do
    @manager.delete_show_episode('series 1', '3')
    File.exists?(@recording_dir + '/series 1/3').should be_false
  end
end