ENV['RACK_ENV'] = 'test'
require 'capybara'
require 'capybara/cucumber'
require 'rspec'

require File.join(File.dirname(__FILE__), '../../lib/simple_pvr')

SimplePvr::PvrInitializer.setup_for_integration_test
SimplePvr::RecordingPlanner.reload

Capybara.app = eval "Rack::Builder.new {( " + SimplePvr::PvrInitializer.rack_maps_file + ")}"
Capybara.default_driver = :selenium
Capybara.default_wait_time = 5
Capybara.ignore_hidden_elements = true # AngularJS shows and hides elements all the time, so this is important

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
