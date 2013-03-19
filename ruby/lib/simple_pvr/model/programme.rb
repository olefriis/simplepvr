module SimplePvr
  module Model
    class Programme
      include DataMapper::Resource
      storage_names[:default] = 'programmes'

      property :id, Serial
      property :title, String, index: true, :length => 255
      property :subtitle, String, :length => 255
      property :description, Text
      property :start_time, DateTime
      property :duration, Integer
      property :episode_num, String, index: true

      belongs_to :channel

      def end_time
        @start_time.advance(seconds: duration)
      end

      def outdated?
        end_time < Time.now
      end

      def self.clear
        Programme.destroy
      end

      def self.add(channel, title, subtitle, description, start_time, duration, episode_num)
        channel.programmes.create(
          channel: channel,
          title: title,
          subtitle: subtitle,
          description: description,
          start_time: start_time,
          duration: duration.to_i,
          episode_num: episode_num)
      end

      def self.with_title(title)
        Programme.all(title: title, order: :start_time)
      end

      def self.on_channel_with_title(channel, title)
        Programme.all(channel: channel, title: title, order: :start_time)
      end

      def self.on_channel_with_title_and_start_time(channel, title, start_time)
        Programme.all(channel: channel, title: title, start_time: start_time)
      end

      def self.titles_containing(text)
        # Maybe there's a smarter way to do substring search than constructing "%#{text}%"? I'd like
        # a version where the original input is escaped properly. However, this method is not
        # dangerous, it just means that the user can enter "%" or "_" in the search string for a
        # wildcard.
        Programme.all(:title.like => "%#{text}%", fields: [:title], order: :title, limit: 8, unique: true).map {|programme| programme.title }
      end

      def self.with_title_containing(text)
        # Same "LIKE" comments as above...
        Programme.all(:title.like => "%#{text}%", order: :start_time, limit: 20)
      end
    end
  end
end