db: immudb -p 3322
websocketd: websocketd --port=8080 ruby bin/gen_inventory.rb
consumer: rake inv_consumer:start
frontend: bundle exec ruby inv_app.rb -o 0.0.0.0 -p 4567
