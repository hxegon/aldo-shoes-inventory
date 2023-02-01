# lib/inventory/client.rb

require 'immudb'

require 'db/key'

module DB
  class Client
    # Don't leak key addresses
    # pass in :host, :port, :username, :password, :database, and :timeout
    def initialize(**config)
      @client = Immudb::Client.new(**config)
    end

    # search for entries with a matching parameter
    def where(**search_hash)
      raise ArgumentError, 'Can only search for one parameter at a time' unless search_hash.count == 1

      @client
        .scan(prefix: DB::Key.partial_value_address(*search_hash.first))
        .each { |result| result[:key] = DB::Key.parse(result[:key]) }
    end

    def find(...)
      where(...).first
    end

    # Takes a DB::Saveable and persists it to immudb
    #
    # We can store transaction times in a key associated with the revision index
    # of the individual keys:
    # Immudb saves a revision index for the individual keys, and the official clients
    # will return this info with the #get method. The ruby immudb client however, only
    # exposes this in one way, and that's through the number of items in the history of
    # a key. Unfortuanately this means we have to get the history of a key every time
    # we want to update it's value.
    def save(saveable)
      set(saveable.to_dbkey, saveable.to_dbval)
    end

    # takes a #to_dbkey and a value, persists to db
    def set(key, val)
      # save value to synonym addresses
      key = key.to_dbkey
      val = val.to_s
      key.value_addresses.each { |addr| @client.set(addr, val) }

      # save transaction times to synonym addresses
      # NOTE:
      # Immudb does *not* include transaction time data in the k/v data by default.
      # This negates a lot of the advantages of bi-temporal DBs, and specifically
      # what I need for historical inventory graphs, so I'm hacking them on to immudb.
      history = @client.history key.value_addresses.first
      now     = Time.now.utc.to_s

      key.txtime_addresses(history.count).each { |r_addr| @client.set(r_addr, now) }
    end

    # returns the field history in chronological order or nil if key isn't found
    def history(search_hash)
      key    = DB::Key.new(search_hash)
      v_addr = key.value_addresses.first

      # Return nil if no matching key instead of erroring
      # TODO: extract
      begin
        history = @client.history(v_addr)
      rescue Immudb::Error
        return nil
      end

      txs = (1.upto history.count).map do |rev_idx|
        {
          rev: rev_idx,
          txtime: get(key.txtime_address(rev_idx))&.then { Time.parse(_1) }
        }
      end

      history.zip(txs).map { |v, tx| v.merge tx }
    end

    # returns key value or nil when no key is found
    # Immudb client throws when #get-ting a key that doesn't exist, I don't like that
    def get(key)
      @client.get key
    rescue Immudb::Error
      nil
    end
  end
end

# immudb = Immudb::Client.new(host: 'localhost', port: 3322, username: 'immudb', password: 'Western:Green:89',
#                         database: 'testdb', timeout: nil)

# db = DB::Client.new(immudb)
