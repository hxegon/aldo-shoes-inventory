#!/usr/bin/env ruby

# TODO: Move into separate environment
require_relative './config/environment'
require 'bundler'
Bundler.require :inv_app

require 'core_ext/hash' # Hash#exchange

require 'sinatra'
require 'chartkick'

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

db = DB::Client.new(host: 'localhost', port: 3322, username: 'immudb', password: 'Western:Green:89',
                    database: 'testdb', timeout: nil)
inventory = DB::Inventory.new db

# How to generate intervals to fill in where updates are blank...
# maybe don't worry about this and just use hour intervals.

# Util for processing data into a chartable format
# @todo refactor
module Charter
  Nearest10Minutes = ->(t) { t.strftime('%Y/%m/%d %H:') + t.min.ceil(-1).to_s }
  NearestHour = ->(t) { t.strftime('%Y/%m/%d %H:00') }

  # chart data of latest revisions for given format of :txtime
  # @param revs array of revisions
  # @param time_formatter block that recives :txtime of revision (Time instance)
  #   Decides how the revisions are grouped
  # @return { datestring => most recent value of revision group, ... }
  # @note doesn't mutate input
  class << self
    def values_by_rev_time(revs, time_formatter: NearestHour)
      revs
        .map { |r| r.exchange(:txtime) { time_formatter.call(_1) } }
        .group_by { _1[:txtime] }
        .transform_values { |revs| revs.sort_by { _1[:rev] }.last[:value] }
    end

    # total inventory for stock_entries for every distinct time of time_formatter
    # NOTE: Doesn't actually do what it says
    # This only counts the inventory totals for groups updated in a time group
    # This would have to take the initial values for every group, and keep a rolling
    # total of it to apply for every time group....
    # reduce with acc hash of group => inv... and process the hash of grouped
    # updates with a rolling total, updating acc and using for the total of every group
    def total_inventory_history(group_entries, group:, time_formatter: NearestHour)
      group_history = group_entries.flat_map do |g, revisions|
        revisions.map { |r| r.merge({ group => g }) }
      end
      # embed model in transaction info and flatten all values

      latest_per_interval = group_history
                            .map { |rev| rev.exchange(:txtime) { time_formatter.call(_1) } }
                            .group_by { _1[:txtime] }
                            .transform_values do |entries|
        # Only keep the latest updates for each group within an interval
        entries
          .group_by { _1[group] }
          .transform_values { |gs| gs.sort_by { _1[:rev] }.last }
          .values
          .map { |e| [e[group], e[:value].to_i] }
          .to_h
      end
      # latest_per_interval = { interval => { group => most recent update during interval } }

      last_known = Hash.new(0)

      # Sum each interval while accounting for models not updated during that interval
      # NOTE: the .sort.to_h is to ensure the hash is processed in chronological order
      latest_per_interval.sort.to_h.transform_values do |update_hash|
        last_known.merge! update_hash
        last_known.values.reduce(0, &:+) # return sum of known group values as of that interval
      end
    end
  end
end

get '/' do
  erb :index, locals: { stores: inventory.all_stores, models: inventory.all_models }
end

# Store detail with total inventory history
get '/model/:model' do
  model = params[:model]
  model_stores = inventory.model_stores(model)
  model_history = inventory.model_history(model)
  model_total_history = Charter.total_inventory_history(model_history, group: :store)

  erb :model_detail, locals: { model:, model_stores:, model_total_history: }
end

# Store detail with total inventory history
get '/store/:store' do # Ensure ALDO prefix
  store = params[:store]
  store_models = inventory.store_models(store)
  store_history = inventory.store_history(store)
  store_total_history = Charter.total_inventory_history(store_history, group: :model)

  erb :store_detail, locals: { store:, store_models:, store_total_history: }
end

# See all stores
get '/stores' do
  stores = inventory.all_stores
  detail_redirect = ->(store) { "/store/#{store}" }
  erb :list_all, locals: { detail_redirect:, name: 'Stores', list: stores }
end

# See all models
get '/models' do
  models = inventory.all_models
  detail_redirect = ->(model) { "/model/#{model}" }
  erb :list_all, locals: { detail_redirect:, name: 'Models', list: models }
end

# TODO: include model and store names in template
get '/history' do
  model = params['model']
  store = params['store']

  return 'need model and store parameters to access history' unless model && params

  history = db.history(store:, model:)

  erb :store_model_history, locals: { history: Charter.values_by_rev_time(history), store:, model: }
end
