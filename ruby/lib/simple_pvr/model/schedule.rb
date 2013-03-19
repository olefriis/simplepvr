module SimplePvr
  module Model
    class Schedule
      include DataMapper::Resource
      storage_names[:default] = 'schedules'

      def self.cleanup
        Schedule.all(:end_time.lt => Time.now).each {|s| s.destroy }
      end

      def self.add_specification(options)
        Schedule.create(
          type: :specification,
          title: options[:title],
          channel: options[:channel],
          start_time: options[:start_time],
          end_time: options[:end_time])
      end
      
      property :id, Serial
      property :type, Enum[:specification, :exception]
      property :title, String, length: 255

      # If specified (and channel is specified too), this schedule is for a specific
      # programme at a specific channel at a specific time
      property :start_time, DateTime
      property :end_time, DateTime

      property :custom_start_early_minutes, Integer
      property :custom_end_late_minutes, Integer

      property :filter_by_time_of_day, Boolean
      property :from_time_of_day, String, length: 5
      property :to_time_of_day, String, length: 5

      property :filter_by_weekday, Boolean
      property :monday, Boolean
      property :tuesday, Boolean
      property :wednesday, Boolean
      property :thursday, Boolean
      property :friday, Boolean
      property :saturday, Boolean
      property :sunday, Boolean

      belongs_to :channel, required: false
    
      def start_early_minutes
        custom_start_early_minutes || 2
      end

      def end_late_minutes
        custom_end_late_minutes || 5
      end
    end
  end
end
