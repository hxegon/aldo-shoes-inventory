# require 'bundler'

require 'bundler/setup'

$:.unshift File.expand_path('lib', __dir__)

# rake spec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) { |t| t.verbose = false }

# rake console
task :console do
  ARGV.clear
  Pry.start
end

namespace 'inv_consumer' do
  desc 'Start the inv_consumer server'
  task :start do
    puts 'Starting inv_consumer'
    exec('ruby inv_consumer/app.rb')
  end
end
