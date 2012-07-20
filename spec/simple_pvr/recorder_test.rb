require './lib/simple_pvr'

SimplePvr::PvrInitializer.setup
MockChannel = Struct.new(:frequency, :channel_id)
recorder = SimplePvr::Recorder.new('test', MockChannel.new(282000000, 1098))
recorder.start!
sleep 5
recorder.stop!