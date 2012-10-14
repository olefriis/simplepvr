require 'active_support/all'

require File.dirname(__FILE__) + '/simple_pvr/pvr_logger'
require File.dirname(__FILE__) + '/simple_pvr/hdhomerun'
require File.dirname(__FILE__) + '/simple_pvr/model/database_initializer'
require File.dirname(__FILE__) + '/simple_pvr/pvr_initializer'
require File.dirname(__FILE__) + '/simple_pvr/recording_planner'
require File.dirname(__FILE__) + '/simple_pvr/recorder'
require File.dirname(__FILE__) + '/simple_pvr/scheduler'
require File.dirname(__FILE__) + '/simple_pvr/recording_manager'
require File.dirname(__FILE__) + '/simple_pvr/ffmpeg'
require File.dirname(__FILE__) + '/simple_pvr/xmltv_reader'

require File.dirname(__FILE__) + '/simple_pvr/server/base_controller'
require File.dirname(__FILE__) + '/simple_pvr/server/app_controller'
require File.dirname(__FILE__) + '/simple_pvr/server/channels_controller'
require File.dirname(__FILE__) + '/simple_pvr/server/programmes_controller'
require File.dirname(__FILE__) + '/simple_pvr/server/schedules_controller'
require File.dirname(__FILE__) + '/simple_pvr/server/shows_controller'
require File.dirname(__FILE__) + '/simple_pvr/server/status_controller'
require File.dirname(__FILE__) + '/simple_pvr/server/upcoming_recordings_controller'
