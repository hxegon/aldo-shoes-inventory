# frozen_string_literal: true

source 'https://rubygems.org'

gem 'dry-monads'
gem 'immudb'
gem 'rake'

group :test, :development do
  gem 'dotenv'
  gem 'rspec'
end

group :inv_consumer do
  gem 'eventmachine'
  gem 'faye-websocket'
end

group :inv_app do
  gem 'puma'
  gem 'sinatra'
  gem 'chartkick'
end
