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

namespace 'frontend' do
  desc 'Start frontend'
  task :start do
    puts 'Starting frontend'
    exec('ruby frontend.rb -o 0.0.0.0 -p 4567')
  end
end

namespace 'consumer' do
  desc 'Start inventory consumer'
  task :start do
    puts 'Starting consumer'
    exec('ruby consumer.rb')
  end
end
