require 'data_mapper'
require 'dm-migrations'

module SimplePvr
  class Channel
    include DataMapper::Resource
    storage_names[:default] = 'channels'
    
    property :id, Serial
    property :name, String
    property :frequency, Integer
    property :channel_id, Integer
    
    has n, :programmes
  end
  
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
  end
  
  class Schedule
    include DataMapper::Resource
    storage_names[:default] = 'schedules'
      
    property :id, Serial
    property :type, Enum[:specification]
    property :title, String

    belongs_to :channel, :required => false
  end
  
  DataMapper.finalize
  
  class Dao
    def initialize(database_file_name = nil)
      database_file_name ||= Dir.pwd + '/database.sqlite'
      DataMapper.setup(:default, "sqlite://#{database_file_name}")
      DataMapper.auto_upgrade!
    end
    
    def clear
      clear_schedules
      clear_programmes
      clear_channels
    end
    
    def add_channel(name, frequency, id)
      Channel.create(
        :name => name,
        :frequency => frequency,
        :channel_id => id
      )
    end
    
    def channels
      Channel.all(:order => :name)
    end
    
    def clear_channels
      Programme.destroy
      Channel.destroy
    end
    
    def number_of_channels
      channels.length
    end
    
    def channel_with_name(name)
      result = Channel.first(:name => name)
      raise "Unknown channel: '#{name}'" unless result
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
        :start_date_time => start_time,
        :duration => duration.to_i)
    end
    
    def programmes_with_title(title)
      Programme.all(:title => title, :order => :start_date_time)
    end
    
    def programmes_on_channel_with_title(channel, title)
      Programme.all(:channel => channel, :title => title, :order => :start_date_time)
    end
    
    def add_schedule_specification(options)
      Schedule.create(
        :type => :specification,
        :title => options[:title],
        :channel => options[:channel])
    end
    
    def schedules
      Schedule.all
    end
    
    def clear_schedules
      Schedule.destroy
    end
  end
end