require File.dirname(__FILE__) + '/lib/simple_pvr'
require File.dirname(__FILE__) + '/lib/simple_pvr/server.rb'

SimplePvr::PvrInitializer.setup
SimplePvr::DatabaseScheduleReader.read
SimplePvr::Server.run!