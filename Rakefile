require 'bundler/setup'
$:.unshift File.expand_path('lib', __dir__)

# rake spec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) { |t| t.verbose = false }

# rake console
task :console do
  require 'pry'
  require 'pry-reload'
  ARGV.clear
  Pry.start
end
