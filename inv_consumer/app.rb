#!/usr/bin/env ruby

require_relative './config/environment'

require 'json'

require 'dry/monads'
require 'faye/websocket'
require 'eventmachine'

require 'inventory/update'

require 'db/client'
require 'db/inventory'

db = DB::Client.new(
  host: 'localhost',
  port: 3322,
  username: 'immudb',
  password: 'Western:Green:89',
  database: 'testdb',
  timeout: nil
)

inventory = DB::Inventory.new db

# Foreman has issues with batching output if this isn't set
# See: https://github.com/ddollar/foreman/issues/450
$stdout.sync = true

puts 'starting server'
EM.run do
  socket = Faye::WebSocket::Client.new('ws://0.0.0.0:8080/')
  include Dry::Monads[:result, :try]

  socket.on :open do |_event|
    puts 'connection opened'
  end

  socket.on :close do |_event|
    puts 'connection closed'
  end

  # messages should be json compatible strings
  socket.on :message do |event|
    msg = event.data

    Try[JSON::ParserError, TypeError] { JSON.parse msg }
      .fmap { |json| Hash(json) }
      .to_result
      .alt_map do |err|
        case err.class
        when JSON::ParserError
          "message isn't parsable as JSON"
        when TypeError
          "message isn't a json object"
        end
      end
      .bind do |hash|
        Inventory::Update.coerce_(hash)
      end
      .either(
        lambda do |invupdate|
          puts "persisting message #{invupdate.to_h}"
          inventory.update(invupdate)
        end,
        lambda do |errors|
          Array(errors).each { |e| puts "Error! message #{msg} had issues: #{e}" }
        end
      )
  end
end
