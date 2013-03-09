module SimplePvr
  class Ffmpeg
    def self.create_thumbnail_for(path)
      thumbnail_file_name = path + '/thumbnail.png'
      log_file_name = path + '/thumbnail.png.log'

      pid = Process.spawn("ffmpeg -i \"#{path}/stream.ts\" -ss 00:05:00.000 -f image2 -vframes 1 -vf scale=300:ih*300/iw \"#{thumbnail_file_name}\" > \"#{log_file_name}\" 2>&1")
      Process.detach(pid)
    end

    def self.transcode_to_webm(path)
      stream_file_name = path + '/stream.ts'
      webm_file_name = path + '/stream.webm'
      log_file_name = path + '/stream.webm.log'

      unless File.exists?(webm_file_name)
        pid = Process.spawn("ffmpeg -i \"#{stream_file_name}\" -b 64k -vf scale=640:ih*640/iw \"#{webm_file_name}\" > \"#{log_file_name}\" 2>&1")
        Process.detach(pid)
      end
    end
  end
end