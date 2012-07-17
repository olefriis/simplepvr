require 'data_mapper'
require 'dm-migrations'

module SimplePvr
  class Programme
    include DataMapper::Resource
    
    property :id, Serial
    property :channel, String
    property :title, String
    property :subtitle, String
    property :description, Text
    property :start_time, DateTime
    property :duration, Integer
  end
  
  DataMapper.finalize
  
  class Dao
    def initialize(database_file_name = nil)
      database_file_name ||= File.dirname(__FILE__) + '/../../database.sqlite'
      puts "Initializing #{database_file_name}"
      DataMapper.setup(:default, "sqlite://#{database_file_name}")
      DataMapper.auto_upgrade!
    end
    
    def clear_programmes
      Programme.destroy
    end
    
    def add_programme(channel, title, subtitle, description, start_time, duration)
      programme = Programme.create(
        :channel => channel,
        :title => title,
        :subtitle => subtitle,
        :description => description,
        :start_time => start_time,
        :duration => duration.to_i)
    end
    
    def programmes_on_channel_with_title(channel, title)
      Programme.all(:channel => channel, :title => title, :order => :start_time)
    end
    
    def programmes_for_channel_on_date(channel, date)
      Programme.all(:channel => channel, :start_time => (date..date+1), :order => :start_time)
    end
    
    def number_of_programmes
      Programme.all.length
    end
  end
end