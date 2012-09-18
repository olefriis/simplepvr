module SimplePvr
  class Ffmpeg
    def self.ensure_thumbnail_exists(path)
      thumbnail_file_name = "#{path}/thumbnail.png"
      return if File.exists?(thumbnail_file_name)

      system "ffmpeg -i \"#{path}/stream.ts\" -ss 00:05:00.000 -f image2 -vframes 1 \"#{thumbnail_file_name}\""
      return if File.exists?(thumbnail_file_name)

      system "ffmpeg -i \"#{path}/stream.ts\" -ss 00:01:00.000 -f image2 -vframes 1 \"#{thumbnail_file_name}\""
      return if File.exists?(thumbnail_file_name)

      FileUtils.copy(File.dirname(__FILE__) + '/resources/default_thumbnail.png', thumbnail_file_name)
      # Take a white image!
    end
  end
end