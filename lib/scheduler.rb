require 'rufus/scheduler'
require File.dirname(__FILE__) + '/channel_information'
require File.dirname(__FILE__) + '/recorder'

class Scheduler
  def initialize
    @scheduler = Rufus::Scheduler.start_new
    @channel_information = ChannelInformation.new
  end
  
  def add(channel, show_name, start_time, duration)
    frequency, id = @channel_information.information_for(channel)

    @scheduler.at start_time do
      recorder = Recorder.new(show_name, frequency, id)
      recorder.start!
      sleep duration
      recorder.stop!
    end
  end
  
  def run!
    @scheduler.join
  end
end