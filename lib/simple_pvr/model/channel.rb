module SimplePvr
  module Model
    class Channel
      include DataMapper::Resource
      storage_names[:default] = 'channels'
    
      property :id, Serial
      property :name, String
      property :frequency, Integer
      property :channel_id, Integer
    
      has n, :programmes
    
      def self.add(name, frequency, id)
        self.create(
          :name => name,
          :frequency => frequency,
          :channel_id => id
        )
      end
    
      def self.sorted_by_name
        self.all(:order => :name)
      end
    
      def self.clear
        Programme.destroy
        self.destroy
      end
    
      def self.with_name(name)
        result = self.first(:name => name)
        raise "Unknown channel: '#{name}'" unless result
        result
      end
    end
  end
end