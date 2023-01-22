#!/usr/bin/env ruby

# Listen for websocket requests

require 'dry/monads'
require 'extensions/monads'

# Going to work my way back here. Handler <- Emitter <- Listener

class EventHandler
  def initialize; end
end

# Websocket Message -> parse json to event -> add to queue -> consume queue -> route event -> handle event -> confirm event handled
# Event examples:
# - inventory change
# - parse error
# - connection open
# - connection closed
# - connection failure
# - listener failure
#
# What can we start here? I think parsing messages is a good start

STORE_STORES = ['ALDO Centre Eaton', 'ALDO Destiny USA Mall', 'ALDO Pheasant Lane Mall', 'ALDO Holyoke Mall',
                'ALDO Maine Mall', 'ALDO Crossgates Mall', 'ALDO Burlington Mall', 'ALDO Solomon Pond Mall', 'ALDO Auburn Mall', 'ALDO Waterloo Premium Outlets']
SHOES_MODELS = %w[ADERI MIRIRA CAELAN BUTAUD SCHOOLER SODANO MCTYRE CADAUDIA RASIEN WUMA
                  GRELIDIEN CADEVEN SEVIDE ELOILLAN BEODA VENDOGNUS ABOEN ALALIWEN GREG BOZZA]

message = {
  'store' => 'ALDO Ste-Catherine',
  'model' => 'ADERI',
  'inventory' => 10
}

# Verify store
class InventoryMessage
  include Dry::Monads[:result, :try, ]

  def self.from_hash_(h)
    Success(h.to_h)
      .unless { |h| (%i[store model inventory] - h.keys).empty? }
      .alt_map { :missing_keys }
  end

  class << self
    def validate(msg)
      List[
        valid_keys?(msg.keys),
        valid_store?(msg[:store])
        valid_model?(msg[:model])
        valid_inventory?(msg[:inventory])
      ]
    end

    private

    def valid_keys?(keys)
      (%i[store model inventory] - keys).empty? ? Success(keys)
    end

    def validate_store(store); end

    def validate_model; end

    def validate_inventory(inventory)
      Try[TypeError] { Integer(inventory) }
        .to_result
        .alt_map { :invalid_inventory }
    end
  end
end

# Event::MessageParser? Event::Parser::Message?
# Should this
module MessageParser
  include Dry::Monads[:try, :result]

  def self.from_hash_
    Success(message)
      .try([NoMethodError], ->(m) { m.to_h.transform_keys!(&:to_sym) })
      .alt_map { |v| EventError.new :invalid_message, v }
  end

  # def self.from_json_; end
end

# Failure Objects
#
# maybe should inherit/include a FailureObject?

class EventError < Struct.new(:event, :on_value, :message, :type)
  def initialize(event, on_value, message: nil, type: :error)
    super event:, on_value:, message:, type:
  end
end

class UnknownEvent
end

class ParseFailure < Struct.new
end

# LATER: Send to RabbitMQ

# Parse and handle events
