require 'data_mapper'
require 'dm-migrations'
require 'active_support/time_with_zone'
require File.dirname(__FILE__) + '/channel'
require File.dirname(__FILE__) + '/programme'
require File.dirname(__FILE__) + '/schedule'
require File.dirname(__FILE__) + '/recording'

DataMapper.finalize

module SimplePvr
  module Model
    class DatabaseInitializer
      def self.setup(database_file_name = nil)
        database_file_name ||= Dir.pwd + '/database.sqlite'
        DataMapper.setup(:default, "sqlite://#{database_file_name}")
        DataMapper.auto_upgrade!
      end
    
      def self.clear
        Schedule.destroy
        Programme.destroy
        Channel.destroy
      end
    
      def self.prepare_for_test
        return if @initialized
      
        @database_file_name = Dir.pwd + '/spec/resources/test.sqlite'
        File.delete(@database_file_name) if File.exists?(@database_file_name)
        self.setup(@database_file_name)
        @initialized = true
      end
    end
  end
end