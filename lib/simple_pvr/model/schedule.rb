module SimplePvr
  module Model
    class Schedule
      include DataMapper::Resource
      storage_names[:default] = 'schedules'
      
      property :id, Serial
      property :type, Enum[:specification]
      property :title, String

      belongs_to :channel, :required => false
    
      def self.add_specification(options)
        Schedule.create(
          :type => :specification,
          :title => options[:title],
          :channel => options[:channel])
      end
    end
  end
end
