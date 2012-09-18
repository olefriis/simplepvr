module SimplePvr
  class Ffmpeg
    def self.create_thumbnail_for(path)
      thumbnail_file_name = path + '/thumbnail.png'
      pid = Process.spawn("ffmpeg -i \"#{path}/stream.ts\" -ss 00:05:00.000 -f image2 -vframes 1 -vf scale=300:ih*300/iw \"#{thumbnail_file_name}\"")
      Process.detach(pid)
    end
  end
end