require 'active_support/all'
require File.dirname(__FILE__) + '/simple_pvr/pvr_initializer'
require File.dirname(__FILE__) + '/simple_pvr/scheduler'
require File.dirname(__FILE__) + '/simple_pvr/database_schedule_reader'
require File.dirname(__FILE__) + '/simple_pvr/recording_manager'

#
# Simple DSL to set up schedules
#

def schedule(&block)
    SimplePvr::PvrInitializer.setup

    pvr = SimplePvr::SimplePvr.new
    pvr.instance_eval &block
    pvr.finish

    SimplePvr::PvrInitializer.sleep_forever
end

module SimplePvr
class SimplePvr
def initialize
    @recording_planner = RecordingPlanner.new
end

def record(show_name, options={})
    if options[:at].nil? && options[:from].nil?
    record_programmes_with_title(show_name)
elsif options[:at].nil?
record_programmes_with_title_on_channel(show_name, options[:from])
else
record_from_timestamp_and_duration(show_name, options[:from], options[:at], options[:for])
end
end

def finish
    @recording_planner.finish
end

private
def record_programmes_with_title(title)
    @recording_planner.specification(title: title)
    end

    def record_programmes_with_title_on_channel(title, channel_name)
        channel = Model::Channel.with_name(channel_name)
        @recording_planner.specification(title: title, channel: channel)
        end

        def record_from_timestamp_and_duration(show_name, channel_name, start_time, duration)
            if duration.nil?
            raise Exception, "No duration specified for recording of '#{show_name}' from '#{channel_name}' at '#{start_time}'"
        end
        channel = Model::Channel.with_name(channel_name)
        @recording_planner.simple(show_name, channel, start_time, duration)
    end
end
end
