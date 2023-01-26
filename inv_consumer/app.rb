#!/usr/bin/env ruby

require_relative './environment'

require 'json'

require 'dry/monads'
require 'faye/websocket'
require 'eventmachine'

require 'inventory/update'

inventory_writer = Ractor.new name: 'MessageConsumer' do
  puts 'starting inventory_writer'

  while true
    update = Ractor.receive
    puts "valid update: #{update.to_h}"
  end
end

# module Inventory::SocketHandler

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
        ->(invupdate) { inventory_writer.send(invupdate) },
        lambda { |errors|
          Array(errors).each do |e|
            puts "Error! message #{msg} had issues: #{e}"
          end
        }
      )
  end
end
