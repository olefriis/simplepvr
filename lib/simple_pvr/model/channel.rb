module SimplePvr
  module Model
    class Channel
      include DataMapper::Resource
      storage_names[:default] = 'channels'
    
      property :id, Serial
      property :name, String
      property :frequency, Integer
      property :channel_id, Integer
      property :icon_url, String, length: 250
      property :hidden, Boolean, required: true, default: false
    
      has n, :programmes
    
      def self.add(name, frequency, id)
        self.create(
          name: name,
          frequency: frequency,
          channel_id: id
        )
      end

      def self.with_current_programmes(id)
        decorated_with_current_programmes(get(id), Time.now)
      end
    
      def self.all_with_current_programmes
        now = Time.now
        self.all(order: :name).map {|channel| decorated_with_current_programmes(channel, now) }
      end
    
      def self.clear
        Programme.destroy
        self.destroy
      end
    
      def self.with_name(name)
        result = self.first(name: name)
        raise "Unknown channel: '#{name}'" unless result
        result
      end

      private
      def self.decorated_with_current_programmes(channel, now)
        current_programme = current_programme_for(channel, now)
        number_of_upcoming_programmes = current_programme ? 3 : 4
        upcoming_programmes = upcoming_programmes_for(channel, number_of_upcoming_programmes, now)
        {
          channel: channel,
          current_programme: current_programme,
          upcoming_programmes: upcoming_programmes
        }
      end

      def self.current_programme_for(channel, now)
        unless channel.hidden
          result = Programme.all(:channel => channel, :start_time.lt => now, fields: [:id, :title, :start_time, :duration], order: :start_time.desc, limit: 1)[0]
          result if result && result.start_time.advance(seconds: result.duration) >= now
        end
      end

      def self.upcoming_programmes_for(channel, limit, now)
        if channel.hidden
          []
        else
          Programme.all(:channel => channel, :start_time.gte => now, fields: [:id, :title, :start_time], order: :start_time, limit: limit)
        end
      end
    end
  end
end