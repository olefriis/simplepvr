require './lib/simple_pvr'

SimplePvr::PvrInitializer.setup
recorder = SimplePvr::Recorder.new('test', 282000000, 1098)
recorder.start!
sleep 5
recorder.stop!