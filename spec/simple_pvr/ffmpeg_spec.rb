require 'simple_pvr'

describe SimplePvr::Ffmpeg do
  it 'does not produce a thumbnail if it already exists' do
    File.should_receive(:exists?).with('path/to/show/thumbnail.png').and_return(true)
    SimplePvr::Ffmpeg.should_not_receive(:system)

    SimplePvr::Ffmpeg.ensure_thumbnail_exists('path/to/show')
  end
  
  it 'produces a thumbnail 5 minutes into the show' do
    File.should_receive(:exists?).with('path/to/show/thumbnail.png').exactly(2).times.and_return(false, true)
    SimplePvr::Ffmpeg.should_receive(:system).with("ffmpeg -i \"path/to/show/stream.ts\" -ss 00:05:00.000 -f image2 -vframes 1 \"path/to/show/thumbnail.png\"")
    
    SimplePvr::Ffmpeg.ensure_thumbnail_exists('path/to/show')
  end
  
  it 'produces a thumbnail 1 minut into the show if it could not produce a thumbnail 5 minutes into the show' do
    File.should_receive(:exists?).with('path/to/show/thumbnail.png').exactly(3).times.and_return(false, false, true)
    SimplePvr::Ffmpeg.should_receive(:system).with("ffmpeg -i \"path/to/show/stream.ts\" -ss 00:05:00.000 -f image2 -vframes 1 \"path/to/show/thumbnail.png\"")
    SimplePvr::Ffmpeg.should_receive(:system).with("ffmpeg -i \"path/to/show/stream.ts\" -ss 00:01:00.000 -f image2 -vframes 1 \"path/to/show/thumbnail.png\"")
    
    SimplePvr::Ffmpeg.ensure_thumbnail_exists('path/to/show')
  end
  
  it 'copies default thumbnail image if FFmpeg does not work' do
    File.should_receive(:exists?).with('path/to/show/thumbnail.png').exactly(3).times.and_return(false, false, false)
    SimplePvr::Ffmpeg.should_receive(:system).exactly(2).times
    FileUtils.should_receive(:copy)
    
    SimplePvr::Ffmpeg.ensure_thumbnail_exists('path/to/show')
  end
end