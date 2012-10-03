ENV['RACK_ENV'] = 'test'
require 'capybara'
require 'capybara/cucumber'
require 'rspec'

require File.join(File.dirname(__FILE__), '../../lib/simple_pvr')
require File.join(File.dirname(__FILE__), '../../lib/simple_pvr/server')

SimplePvr::PvrInitializer.setup_for_integration_test
SimplePvr::RecordingPlanner.read

Capybara.app = SimplePvr::Server
Capybara.default_driver = :selenium
Capybara.default_wait_time = 5

class SimplePvrWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  SimplePvrWorld.new
end

Before do
  SimplePvr::Model::DatabaseInitializer.clear
end
