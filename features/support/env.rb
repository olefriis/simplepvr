ENV['RACK_ENV'] = 'test'
require 'capybara'
require 'capybara/cucumber'
require 'rspec'

require File.join(File.dirname(__FILE__), '../../lib/simple_pvr')
require File.join(File.dirname(__FILE__), '../../lib/simple_pvr/server')

SimplePvr::PvrInitializer.setup_for_integration_test
SimplePvr::DatabaseScheduleReader.read

Capybara.app = SimplePvr::Server
Capybara.default_driver = :selenium

class SimplePvrWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  SimplePvrWorld.new
end

Before do
  #SimplePvr::Model::DatabaseInitializer.clear
end
