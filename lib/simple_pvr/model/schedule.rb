module SimplePvr
  module Model
    class Schedule
      include DataMapper::Resource
      storage_names[:default] = 'schedules'
      
      property :id, Serial
      property :type, Enum[:specification]
      property :title, String, :length => 255
      property :start_time, DateTime

      belongs_to :channel, required: false
    
      def self.add_specification(options)
        Schedule.create(
          type: :specification,
          title: options[:title],
          channel: options[:channel],
          start_time: options[:start_time])
      end
    end
  end
end
