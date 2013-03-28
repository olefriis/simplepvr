# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_pvr/version'

Gem::Specification.new do |gem|
  gem.name          = 'simple_pvr'
  gem.version       = SimplePvr::VERSION
  gem.authors       = ["Ole Friis"]
  gem.email         = ["olefriis@gmail.com"]
  gem.description   = 'TV recorder for the HDHomeRun tuners. XMLTV support, nice web GUI for planning your recordings. No playback functionality - use e.g. VLC for that.'
  gem.summary       = 'PVR made simple, not dumb'
  gem.homepage      = 'https://github.com/olefriis/simplepvr'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '~> 3.2'
  gem.add_dependency 'nokogiri', '~> 1.5'
  gem.add_dependency 'data_mapper', '~> 1.2'
  gem.add_dependency 'dm-sqlite-adapter', '~> 1.2'
  gem.add_dependency 'sinatra', '~> 1.3'
  gem.add_dependency 'puma', '~> 1.6'

  gem.add_development_dependency 'rake', '>= 10.0.0'
  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'cucumber', '~> 1.2'
  gem.add_development_dependency 'capybara', '~> 2.0'
end
