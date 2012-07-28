require File.dirname(__FILE__) + '/pvr_initializer'
require File.dirname(__FILE__) + '/dao'
require File.dirname(__FILE__) + '/recording_planner'

module SimplePvr
  class DatabaseScheduleReader
    def self.read
      @dao = PvrInitializer.dao
      @recording_planner = RecordingPlanner.new
      
      @dao.schedules.each do |schedule|
        puts "Schedule: #{schedule.title}"
        @recording_planner.specification(title: schedule.title, channel: schedule.channel)
      end
      
      @recording_planner.finish
    end
  end
end
