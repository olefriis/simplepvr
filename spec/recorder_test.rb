require './lib/simple_pvr/recorder'

recorder = SimplePvr::Recorder.new('test', 282000000, 1098)
recorder.start!
sleep 5
recorder.stop!