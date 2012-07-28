require File.dirname(__FILE__) + '/pvr_initializer'
require File.dirname(__FILE__) + '/model/database_initializer'
require File.dirname(__FILE__) + '/recording_planner'

module SimplePvr
  class DatabaseScheduleReader
    def self.read
      @recording_planner = RecordingPlanner.new
      
      Model::Schedule.all.each do |schedule|
        @recording_planner.specification(title: schedule.title, channel: schedule.channel)
      end
      
      @recording_planner.finish
    end
  end
end
