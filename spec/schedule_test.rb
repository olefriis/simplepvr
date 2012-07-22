require './lib/simple_pvr'

schedule do
  record 'test', from:'TV4 Sverige', at:Time.now, for:5.seconds
end
