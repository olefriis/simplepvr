module SimplePvr
  module Server
    class ShowsController < BaseController
      get '/' do
        shows = PvrInitializer.recording_manager.shows
        shows.map do |show|
          {
            id: show,
            name: show
          }
        end.to_json
      end

      get '/:id/?' do |id|
        {
          id: id,
          name: id
        }.to_json
      end

      delete '/:id/?' do |id|
        PvrInitializer.recording_manager.delete_show(id)
        ''
      end

      get '/:show_id/recordings/?' do |show_id|
        recordings = PvrInitializer.recording_manager.episodes_of(show_id)
        recordings.map {|recording| recording_hash(show_id, recording) }.to_json
      end

      get '/:show_id/recordings/:recording_id/?' do |show_id, recording_id|
        recording = PvrInitializer.recording_manager.metadata_for(show_id, recording_id)
        recording_hash(show_id, recording).to_json
      end

      delete '/:show_id/recordings/:episode' do |show_id, episode|
        PvrInitializer.recording_manager.delete_show_episode(show_id, episode)
        ''
      end

      get '/:show_id/recordings/:recording_id/thumbnail.png' do |show_id, recording_id|
        path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
        send_file File.join(path, 'thumbnail.png')
      end

      get '/:show_id/recordings/:recording_id/stream.ts' do |show_id, recording_id|
        path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
        send_file File.join(path, 'stream.ts')
      end

      get '/:show_id/recordings/:recording_id/stream.webm' do |show_id, recording_id|
        path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
        send_file File.join(path, 'stream.webm'), type: :webm
      end

      post '/:show_id/recordings/:recording_id/transcode' do |show_id, recording_id|
        path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
        Ffmpeg.transcode_to_webm(path)
        ''
      end
    end
  end
end