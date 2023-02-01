#!/usr/bin/env ruby
# frozen_string_literal: true

require 'dry/monads'
require 'db/saveable'
require 'db/key'
require 'invlib/monadic/coercible'

module Inventory
  class Update
    extend Dry::Monads[:result, :try]
    include Dry::Monads[:result, :try]

    attr_reader :store, :model, :inventory

    def initialize(opts = {}, store: nil, model: nil, inventory: nil)
      @store     = store || opts[:store]
      @model     = model || opts[:model]
      @inventory = inventory || opts[:inventory]
    end

    # Conversions
    def to_h
      { model: @model, inventory: @inventory, store: @store }
    end
    alias to_hash to_h

    # Mixin Methods
    include DB::Saveable

    def to_dbkey
      DB::Key.new(to_h.slice(:model, :store))
    end

    def to_dbval
      inventory
    end

    extend InvLib::Monadic::Coercible

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
