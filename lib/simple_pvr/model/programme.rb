module SimplePvr
  module Model
    class Programme
      include DataMapper::Resource
      storage_names[:default] = 'programs'
    
      property :id, Serial
      property :title, String, index: true
      property :subtitle, String
      property :description, Text
      property :start_date_time, DateTime
      property :duration, Integer
    
      belongs_to :channel

      # DataMapper loads only the date part of Time, but we want the whole thing.
      # Thus, we convert a bit.
      def start_time
        start_date_time.to_time
      end
    
      def start_time=(time)
        start_date_time = time
      end
      
      def self.clear
        Programme.destroy
      end

      def self.add(channel_name, title, subtitle, description, start_time, duration)
        channel = Channel.first(:name => channel_name)
        raise Exception, "Unknown channel: #{channel_name}" unless channel
        channel.programmes.create(
          :channel => channel,
          :title => title,
          :subtitle => subtitle,
          :description => description,
          :start_date_time => start_time,
          :duration => duration.to_i)
      end

      def self.with_title(title)
        Programme.all(:title => title, :order => :start_date_time)
      end

      def self.on_channel_with_title(channel, title)
        Programme.all(:channel => channel, :title => title, :order => :start_date_time)
      end
    end
  end
end