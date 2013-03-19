module SimplePvr
  module Server
    class ChannelsController < BaseController
      get '/' do
        Model::Channel.all_with_current_programmes.map do |channel_with_current_programmes|
          channel_with_current_programmes_hash(channel_with_current_programmes)
        end.to_json
      end

      get '/:id' do |id|
        channel_with_current_programmes_hash(Model::Channel.with_current_programmes(id)).to_json
      end

      post '/:id/hide' do |id|
        channel = Model::Channel.get(id)
        channel.hidden = true
        channel.save
        {
          id: channel.id,
          name: channel.name,
          hidden: channel.hidden
        }.to_json
      end

      post '/:id/show' do |id|
        channel = Model::Channel.get(id)
        channel.hidden = false
        channel.save
        {
          id: channel.id,
          name: channel.name,
          hidden: channel.hidden
        }.to_json
      end

      get '/:channel_id/programme_listings/:date/?' do |channel_id, date_string|
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
            programmes: programme_summaries_hash(programmes)
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
    end
  end
end
