require 'rufus/scheduler'
require './recorder'

scheduler = Rufus::Scheduler.start_new

#scheduler.at 'Thu Jul 12 22:28:00 +0200 2012' do
scheduler.at 'Tue Jul 10 20:46:00 +0200 2012' do
  recorder = Recorder.new('borgias', '12106FA4', 282000000, 1098)
  recorder.start!
  sleep 5*60
  recorder.stop!
end

scheduler.join