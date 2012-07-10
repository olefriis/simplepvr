require File.dirname(__FILE__) + '/recorder'

recorder = Recorder.new('dr-k', '12106FA4', 282000000, 1098)
recorder.start!
sleep 5
recorder.stop!