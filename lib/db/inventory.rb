# lib/db/inventory.rb

require 'immudb'
require 'db/client'

# This would be way simpler with models/stores extracted
module DB
  class Inventory
    def initialize(db_client)
      @client = db_client
    end

    def update(update)
      @client.save(update)
    end

    # TODO: Combine model/store methods

    # TODO: models and store lists caches are never invalidated, so
    # any new models or stores won't be listed.

    def all_models
      @models ||=
        @client
        .where(model: '')
        .map { _1[:key].to_h[:model] }
        .uniq
    end

    def all_stores
      @stores ||=
      @client
      .where(store: '')
      .map { _1[:key].to_h[:store] }
      .uniq
    end

    # { model_name => stock_level } associated with store
    # Returns [] if no store is found or store has no inventory
    def store_models(store)
      models = @client.where(store:)
      models&.map { |m| [m[:key][:model], m[:value].to_i] }.to_h
    end

    # { store_name => stock_level } associated with model
    # Returns [] if no model is found or model has no inventory
    def model_stores(model)
      models = @client.where(model:)
      models&.map { |m| [m[:key][:store], m[:value].to_i] }.to_h
    end

    # store's { model => model history }
    def store_history(store)
      models = @client.where(store:)
      models.map { |m| [m[:key][:model], @client.history(m[:key])] }.to_h
    end

    # model's { store => model history }
    def model_history(model)
      models = @client.where(model:)
      models.map { |m| [m[:key][:store], @client.history(m[:key])] }.to_h
    end

    def history(**kwargs)
      @client.history kwargs.slice(:store, :model)
    end
  end
end
