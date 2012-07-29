module SimplePvr
  module Model
    class Programme
      include DataMapper::Resource
      storage_names[:default] = 'programmes'
    
      property :id, Serial
      property :title, String, index: true
      property :subtitle, String
      property :description, Text
      property :start_time, DateTime
      property :duration, Integer
    
      belongs_to :channel

      def self.clear
        Programme.destroy
      end

      def self.add(channel, title, subtitle, description, start_time, duration)
        channel.programmes.create(
          :channel => channel,
          :title => title,
          :subtitle => subtitle,
          :description => description,
          :start_time => start_time,
          :duration => duration.to_i)
      end

      def self.with_title(title)
        Programme.all(:title => title, :order => :start_time)
      end

      def self.on_channel_with_title(channel, title)
        Programme.all(:channel => channel, :title => title, :order => :start_time)
      end
    end
  end
end