require 'sinatra/base'

Time::DATE_FORMATS[:programme_date] = '%F'
Time::DATE_FORMATS[:day] = '%a, %d %b'

module SimplePvr
  module Server
    class BaseController < Sinatra::Base
      include ERB::Util

      http_username, http_password = ENV['username'], ENV['password']
      if http_username && http_password
        PvrLogger.info('Securing server with Basic HTTP Authentication')
        use Rack::Auth::Basic, 'Restricted Area' do |username, password|
          [username, password] == [http_username, http_password]
        end
      else
        PvrLogger.info('Beware: Unsecured server. Do not expose to the rest of the world!')
      end

      configure do
        set :public_folder, File.dirname(__FILE__) + '/../../../public/'
        mime_type :webm, 'video/webm'
      end

      def reload_schedules
        RecordingPlanner.reload
      end

      def programme_hash(programme)
        {
          id: programme.id,
          channel: { id: programme.channel.id, name: programme.channel.name },
          title: programme.title,
          subtitle: programme.subtitle,
          description: programme.description,
          start_time: programme.start_time,
          is_scheduled: PvrInitializer.scheduler.scheduled?(programme),
          episode_num: programme.episode_num,
          is_outdated: programme.outdated?
        }
      end

      def recording_hash(show_id, recording)
        path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording.episode)
        {
          id: recording.episode,
          show_id: show_id,
          episode: recording.episode,
          subtitle: recording.subtitle,
          description: recording.description,
          start_time: recording.start_time,
          channel_name: recording.channel,
          has_thumbnail: recording.has_thumbnail,
          has_webm: recording.has_webm,
          local_file_url: 'file://' + File.join(path, 'stream.ts')
        }
      end

      def channel_with_current_programmes_hash(channel_with_current_programmes)
        channel = channel_with_current_programmes[:channel]
        current_programme = channel_with_current_programmes[:current_programme]
        upcoming_programmes = channel_with_current_programmes[:upcoming_programmes]

        current_programme_map = current_programme ? programme_summary_hash(current_programme) : nil
        upcoming_programmes_map = programme_summaries_hash(upcoming_programmes)

        {
          id: channel.id,
          name: channel.name,
          hidden: channel.hidden,
          icon_url: channel.icon_url,
          current_programme: channel,
          current_programme: current_programme_map,
          upcoming_programmes: upcoming_programmes_map
        }
      end
    
      def programme_summaries_hash(programmes)
        programmes.map {|programme| programme_summary_hash(programme) }
      end
    
      def programme_summary_hash(programme)
        {
          id: programme.id,
          title: programme.title,
          start_time: programme.start_time,
          is_scheduled: PvrInitializer.scheduler.scheduled?(programme),
          is_conflicting: PvrInitializer.scheduler.conflicting?(programme)
        }
      end
    end
  end
end