require 'data_mapper'
require 'dm-migrations'

module SimplePvr
  class Channel
    include DataMapper::Resource
    
    property :id, Serial
    property :name, String
    property :frequency, Integer
    property :channel_id, Integer
    
    has n, :programmes
  end
  
  class Programme
    include DataMapper::Resource
    
    property :id, Serial
    property :title, String, index: true
    property :subtitle, String
    property :description, Text
    property :start_time, DateTime
    property :duration, Integer
    
    belongs_to :channel
  end
  
  DataMapper.finalize
  
  class Dao
    def initialize(database_file_name = nil)
      database_file_name ||= Dir.pwd + '/database.sqlite'
      DataMapper.setup(:default, "sqlite://#{database_file_name}")
      DataMapper.auto_upgrade!
    end
    
    def add_channel(name, frequency, id)
      Channel.create(
        :name => name,
        :frequency => frequency,
        :channel_id => id
      )
    end
    
    def clear_channels
      Programme.destroy
      Channel.destroy
    end
    
    def number_of_channels
      Channel.all.length
    end
    
    def channel_with_name(name)
      result = Channel.first(:name => name)
      raise "Unknown channel: #{name}" unless result
      result
    end
    
    def clear_programmes
      Programme.destroy
    end
    
    def number_of_programmes
      Programme.all.length
    end
    
    def add_programme(channel_name, title, subtitle, description, start_time, duration)
      channel = Channel.first(:name => channel_name)
      raise Exception, "Unknown channel: #{channel_name}" unless channel
      channel.programmes.create(
        :channel => channel,
        :title => title,
        :subtitle => subtitle,
        :description => description,
        :start_time => start_time,
        :duration => duration.to_i)
    end
    
    def programmes_with_title(title)
      Programme.all(:title => title, :order => :start_time)
    end
    
    def programmes_on_channel_with_title(channel_name, title)
      Programme.all(:channel => { name: channel_name }, :title => title, :order => :start_time)
    end
  end
end