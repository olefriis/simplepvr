require 'directory_creator'

describe DirectoryCreator do
  it 'creates directory with number 1 if nothing exists' do
    Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(false)
    FileUtils.should_receive(:makedirs).with('recordings/Star Trek/1')
    
    DirectoryCreator.create_for_show('Star Trek').should == 'recordings/Star Trek/1'
  end
  
  it 'finds next number in sequence for new directory' do
    Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(true)
    Dir.should_receive(:new).with('recordings/Star Trek').and_return(['1', '2', '3'])
    FileUtils.should_receive(:makedirs).with('recordings/Star Trek/4')
    
    DirectoryCreator.create_for_show('Star Trek').should == 'recordings/Star Trek/4'
  end
  
  it 'ignores random directories which are not sequence numbers' do
    Dir.should_receive(:exists?).with('recordings/Star Trek').and_return(true)
    Dir.should_receive(:new).with('recordings/Star Trek').and_return(['4', 'random directory name', '..'])
    FileUtils.should_receive(:makedirs).with('recordings/Star Trek/5')
    
    DirectoryCreator.create_for_show('Star Trek').should == 'recordings/Star Trek/5'
  end
end