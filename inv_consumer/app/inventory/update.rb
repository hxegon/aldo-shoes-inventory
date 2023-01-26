#!/usr/bin/env ruby
# frozen_string_literal: true

require 'dry/monads'

require 'invlib/monadic/coercable'
module Inventory
  class Update
    extend Dry::Monads[:result, :try]
    include Dry::Monads[:result, :try]

    extend InvLib::Monadic::Coercable

    attr_reader :id, :store, :model, :inventory

    def initialize(opts = {}, store: nil, model: nil, inventory: nil)
      # Ruby has deprecated using hashes as arguments to methods using kwargs, weird
      @store     = store || opts[:store]
      @model     = model || opts[:model]
      @inventory = inventory || opts[:inventory]
    end

    # Doesn't do anything right now but planning on using it in the future
    def id
      @id ||= SecureRandom.hex(4)
    end

    def to_h
      { update_id: @id, model: @model, inventory: @inventory, store: @store }
    end
    alias to_hash to_h

    def self.coerce_(obj)
      super(
        obj,
        # Is obj hashable?
        ->(v) { Try[NoMethodError] { v.to_h }.or { |err| Failure(err.to_s) } },
        # Does it have the right keys?
        lambda do |h|
          candidates =
            h.slice(*%i[store model inventory].flat_map { [_1, _1.to_s] })
             .transform_keys(&:to_sym)

          missing = (%i[store model inventory] - candidates.keys).map { "No #{_1} found" }

          missing.empty? ? candidates : Failure(missing)
        end,
        # Is inventory val Integer-able?
        lambda do |h|
          Try[TypeError, ArgumentError] { h.merge inventory: Integer(h[:inventory]) }
            .or(Failure("Inventory wasn't an Integer type"))
        end
      )
    end
  end
end
