require 'sinatra/base'

Time::DATE_FORMATS[:programme_date] = '%F'
Time::DATE_FORMATS[:day] = '%a, %d %b'

module SimplePvr
  class Server < Sinatra::Base
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
      set :public_folder, File.dirname(__FILE__) + '/../../public/'
      mime_type :webm, 'video/webm'
    end

    get '/api/schedules/?' do
      Model::Schedule.all.map do |schedule|
        {
          id: schedule.id,
          title: schedule.title,
          channel: schedule.channel ? { id: schedule.channel.id, name: schedule.channel.name } : nil,
          start_time: schedule.start_time
        }
      end.to_json
    end

    post '/api/schedules/?' do
      parameters = JSON.parse(request.body.read)
      title, channel_id, channel = parameters['title'], parameters['channel_id'].to_i, nil
      puts "Title: #{title}, channel: #{channel_id}"
      channel = Model::Channel.get(channel_id) if channel_id > 0
      result = Model::Schedule.add_specification(title: title, channel: channel)
      reload_schedules
      result.to_json
    end

    delete '/api/schedules/:id' do |id|
      Model::Schedule.get(id).destroy
      reload_schedules
      ''
    end

    get '/api/upcoming_recordings/?' do
      PvrInitializer.scheduler.upcoming_recordings.map do |recording|
        {
          programme_id: recording.programme.id,
          show_name: recording.show_name,
          start_time: recording.start_time,
          channel: { id: recording.channel.id, name: recording.channel.name },
          subtitle: recording.programme ? recording.programme.subtitle : nil,
          description: recording.programme ? recording.programme.description : nil
        }
      end.to_json
    end

    post '/api/schedules/reload' do
      reload_schedules
    end

    get '/api/channels/?' do
      Model::Channel.all_with_current_programmes.map do |channel_with_current_programmes|
        channel_with_current_programmes_hash(channel_with_current_programmes)
      end.to_json
    end

    get '/api/channels/:id' do |id|
      channel_with_current_programmes_hash(Model::Channel.with_current_programmes(id)).to_json
    end

    post '/api/channels/:id/hide' do |id|
      channel = Model::Channel.get(id)
      channel.hidden = true
      channel.save
      {
        id: channel.id,
        name: channel.name,
        hidden: channel.hidden
      }.to_json
    end

    post '/api/channels/:id/show' do |id|
      channel = Model::Channel.get(id)
      channel.hidden = false
      channel.save
      {
        id: channel.id,
        name: channel.name,
        hidden: channel.hidden
      }.to_json
    end

    get '/api/channels/:channel_id/programme_listings/:date/?' do |channel_id, date_string|
      if date_string == 'today'
        now = Time.now
        this_date = Time.local(now.year, now.month, now.day)
      else
        this_date = Time.parse(date_string)
      end
      previous_date = this_date.advance(days: -7)
      next_date = this_date.advance(days: 7)
      channel = Model::Channel.get(channel_id)

      days = (0..6).map do |date_advanced|
        from_date = this_date.advance(days: date_advanced)
        to_date = this_date.advance(days: date_advanced + 1)
        programmes = Model::Programme.all(channel: channel, start_time: (from_date..to_date), order: :start_time)

        {
          date: from_date.to_s(:programme_date),
          programmes: programmes.map do |programme|
            {
              id: programme.id,
              start_time: programme.start_time,
              title: programme.title,
              scheduled: PvrInitializer.scheduler.is_scheduled?(programme)
            }
          end
        }
      end
  
      {
        channel: { id: channel.id, name: channel.name,  icon_url: channel.icon_url },
        previous_date: previous_date.to_s(:programme_date),
        this_date: this_date.to_s(:programme_date),
        next_date: next_date.to_s(:programme_date),
        days: days
      }.to_json
    end

    get '/api/programmes/title_search' do
      Model::Programme.titles_containing(params['query']).to_json
    end

    get '/api/programmes/search' do
      Model::Programme.with_title_containing(params['query']).map {|programme| programme_hash(programme) }.to_json
    end

    get '/api/programmes/:id' do |id|
      programme = Model::Programme.get(id)
      programme_hash(programme).to_json
    end

    post '/api/programmes/:id/record_on_any_channel' do |id|
      programme = Model::Programme.get(id.to_i)
      Model::Schedule.add_specification(title: programme.title)
      reload_schedules
      programme_hash(programme).to_json
    end

    post '/api/programmes/:id/record_on_this_channel' do |id|
      programme = Model::Programme.get(id.to_i)
      Model::Schedule.add_specification(title: programme.title, channel: programme.channel)
      reload_schedules
      programme_hash(programme).to_json
    end

    post '/api/programmes/:id/record_just_this_programme' do |id|
      puts "Record just this programme #{id}"
      programme = Model::Programme.get(id.to_i)
      Model::Schedule.add_specification(title: programme.title, channel: programme.channel, start_time: programme.start_time)
      reload_schedules
      programme_hash(programme).to_json
    end

    get '/api/shows' do
      shows = PvrInitializer.recording_manager.shows
      shows.map do |show|
        {
          id: show,
          name: show
        }
      end.to_json
    end

    get '/api/shows/:id/?' do |id|
      {
        id: id,
        name: id
      }.to_json
    end

    delete '/api/shows/:id/?' do |id|
      PvrInitializer.recording_manager.delete_show(id)
      ''
    end

    get '/api/shows/:show_id/recordings/?' do |show_id|
      recordings = PvrInitializer.recording_manager.episodes_of(show_id)
      recordings.map {|recording| recording_hash(show_id, recording) }.to_json
    end

    get '/api/shows/:show_id/recordings/:recording_id/?' do |show_id, recording_id|
      recording = PvrInitializer.recording_manager.metadata_for(show_id, recording_id)
      recording_hash(show_id, recording).to_json
    end

    delete '/api/shows/:show_id/recordings/:episode' do |show_id, episode|
      PvrInitializer.recording_manager.delete_show_episode(show_id, episode)
      ''
    end
    
    get '/api/shows/:show_id/recordings/:recording_id/thumbnail.png' do |show_id, recording_id|
      path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
      send_file File.join(path, 'thumbnail.png')
    end

    get '/api/shows/:show_id/recordings/:recording_id/stream.ts' do |show_id, recording_id|
      path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
      send_file File.join(path, 'stream.ts')
    end

    get '/api/shows/:show_id/recordings/:recording_id/stream.webm' do |show_id, recording_id|
      path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
      send_file File.join(path, 'stream.webm'), type: :webm
    end

    post '/api/shows/:show_id/recordings/:recording_id/transcode' do |show_id, recording_id|
      path = PvrInitializer.recording_manager.directory_for_show_and_episode(show_id, recording_id)
      Ffmpeg.transcode_to_webm(path)
      ''
    end

    get '/api/status' do
      {
        status_text: PvrInitializer.scheduler.status_text
      }.to_json
    end

    get '/app/*' do |path|
      send_file File.join(settings.public_folder, path)
    end

    get '/*' do
      send_file File.join(settings.public_folder, 'index.html')
    end

    def reload_schedules
      DatabaseScheduleReader.read
    end

    def programme_hash(programme)
      is_scheduled = PvrInitializer.scheduler.is_scheduled?(programme)
      {
        id: programme.id,
        channel: { id: programme.channel.id, name: programme.channel.name },
        title: programme.title,
        subtitle: programme.subtitle,
        description: programme.description,
        start_time: programme.start_time,
        is_scheduled: is_scheduled,
        episode_num: programme.episode_num
      }
    end

    def recording_hash(show_id, recording)
      {
        id: recording.episode,
        show_id: show_id,
        episode: recording.episode,
        subtitle: recording.subtitle,
        description: recording.description,
        start_time: recording.start_time,
        channel_name: recording.channel,
        has_thumbnail: recording.has_thumbnail,
        has_webm: recording.has_webm
      }
    end

    def channel_with_current_programmes_hash(channel_with_current_programmes)
      channel = channel_with_current_programmes[:channel]
      current_programme = channel_with_current_programmes[:current_programme]
      upcoming_programmes = channel_with_current_programmes[:upcoming_programmes]

      current_programme_map = current_programme ?
        {
          id: current_programme.id,
          title: current_programme.title,
          start_time: current_programme.start_time
        } :
        nil
      upcoming_programmes_map = upcoming_programmes.map do |programme|
        {
          id: programme.id,
          title: programme.title,
          start_time: programme.start_time
        }
      end

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
  end
end