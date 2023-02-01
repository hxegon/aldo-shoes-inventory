db: immudb -p 3322
websocketd: websocketd --port=8080 ruby bin/gen_inventory.rb
consumer: rake inv_consumer:start
