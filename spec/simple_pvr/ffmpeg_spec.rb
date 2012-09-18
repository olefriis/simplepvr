require 'simple_pvr'

describe SimplePvr::Ffmpeg do
  it 'spawns an ffmpeg process for creating thumbnails' do
    Process.should_receive(:spawn)
    Process.should_receive(:detach)

    SimplePvr::Ffmpeg.create_thumbnail_for('path/to/show')
  end
end