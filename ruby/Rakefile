require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

directory 'output'

namespace :test do
  RSpec::Core::RakeTask.new(:spec)
  Cucumber::Rake::Task.new(:features)
  task :javascript do
  	sh 'karma start test/karma.conf.js --singleRun'
  end
end
  
desc 'Run specs and features'
task :test => ['test:spec', 'test:features', 'test:javascript']

task :default => ['test']