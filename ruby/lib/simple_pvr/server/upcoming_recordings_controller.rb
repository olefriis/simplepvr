module SimplePvr
  module Server
    class UpcomingRecordingsController < BaseController
      get '/' do
        PvrInitializer.scheduler.upcoming_recordings.map do |recording|
          {
            programme_id: recording.programme.id,
            show_name: recording.show_name,
            start_time: recording.start_time,
            channel: { id: recording.channel.id, name: recording.channel.name },
            subtitle: recording.programme.subtitle,
            is_conflicting: PvrInitializer.scheduler.conflicting?(recording.programme)
          }
        end.to_json
      end
    end
  end
end