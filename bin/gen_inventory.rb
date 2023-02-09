#!/usr/bin/env ruby

require 'json'

STDOUT.sync = true

# TODO: Load these from DB
STORE_STORES = ['ALDO Centre Eaton', 'ALDO Destiny USA Mall', 'ALDO Pheasant Lane Mall', 'ALDO Holyoke Mall',
                'ALDO Maine Mall', 'ALDO Crossgates Mall', 'ALDO Burlington Mall', 'ALDO Solomon Pond Mall', 'ALDO Auburn Mall', 'ALDO Waterloo Premium Outlets']
SHOES_MODELS = %w[ADERI MIRIRA CAELAN BUTAUD SCHOOLER SODANO MCTYRE CADAUDIA RASIEN WUMA
                  GRELIDIEN CADEVEN SEVIDE ELOILLAN BEODA VENDOGNUS ABOEN ALALIWEN GREG BOZZA]
INVENTORY = Array(0..100)
# RANDOMNESS = Array(1..3)
RANDOMNESS = Array(1..2)

loop do
  RANDOMNESS.sample.times do
    puts JSON.generate({
                         store: STORE_STORES.sample,
                         model: SHOES_MODELS.sample,
                         inventory: INVENTORY.sample
                       }, quirks_mode: true)
  end
  # sleep 1
  sleep 3
end
