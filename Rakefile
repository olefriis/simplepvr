require "bundler/setup"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

directory 'output'

namespace :test do
  RSpec::Core::RakeTask.new(:spec)
  Cucumber::Rake::Task.new(:features)
end
  
desc 'Run specs and features'
task :test => ['test:spec', 'test:features']

namespace :xbmc do
  desc 'Package XBMC plug-in'
  task :package => 'output' do
    zip_file_name = 'output/plugin.video.simplepvr.zip'
    File.delete zip_file_name if File.exists? zip_file_name
    chdir("plugins/xbmc") do
      `zip -r ../../#{zip_file_name} plugin.video.simplepvr`
    end
  end
end

task :default => ['test', 'xbmc:package']