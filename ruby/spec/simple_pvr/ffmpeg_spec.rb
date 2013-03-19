require 'simple_pvr'

describe SimplePvr::Ffmpeg do
  it 'spawns an ffmpeg process for creating thumbnails' do
    Process.should_receive(:spawn)
    Process.should_receive(:detach)

    SimplePvr::Ffmpeg.create_thumbnail_for('path/to/show')
  end

  it 'spawns an ffmpeg process for transcoding to WebM' do
    File.should_receive(:exists?).with('path/to/show/stream.webm').and_return(false)
    Process.should_receive(:spawn)
    Process.should_receive(:detach)

    SimplePvr::Ffmpeg.transcode_to_webm('path/to/show')
  end

  it 'does not start ffmpeg for transcoding to WebM if WebM file already exists' do
    File.should_receive(:exists?).with('path/to/show/stream.webm').and_return(true)
    Process.should_not_receive(:spawn)
    Process.should_not_receive(:detach)

    SimplePvr::Ffmpeg.transcode_to_webm('path/to/show')
  end
end