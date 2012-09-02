ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', '..', 'pvr_server.rb')

require 'capybara'
require 'capybara/cucumber'
require 'rspec'

Capybara.app = Sinatra::Application
Capybara.default_driver = :selenium

class SimplePvrWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  SimplePvrWorld.new
end
