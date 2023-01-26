#!/usr/bin/env ruby

require 'securerandom'

require 'logger'

# TODO: Set log level based on env var
# IE $logger.level = Logger::WARN
$logger = Logger.new($stdout)

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

test_message = {
  'store' => 'ALDO Ste-Catherine',
  'model' => 'ADERI',
  'inventory' => 10
}
