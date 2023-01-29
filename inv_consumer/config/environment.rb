#!/usr/bin/env ruby

require 'bundler'

Bundler.require(:default, :inv_consumer)

paths = ['../../lib', '../lib', '../app'].map { File.expand_path _1, __dir__ }

$LOAD_PATH.unshift(*paths)

# FIXME: Temporary for Inventory::Update testing, need to read these from somewhere
SHOE_STORES = ['ALDO Centre Eaton', 'ALDO Destiny USA Mall', 'ALDO Pheasant Lane Mall', 'ALDO Holyoke Mall',
               'ALDO Maine Mall', 'ALDO Crossgates Mall', 'ALDO Burlington Mall', 'ALDO Solomon Pond Mall', 'ALDO Auburn Mall', 'ALDO Waterloo Premium Outlets']

SHOE_MODELS = %w[ADERI MIRIRA CAELAN BUTAUD SCHOOLER SODANO MCTYRE CADAUDIA RASIEN WUMA
                 GRELIDIEN CADEVEN SEVIDE ELOILLAN BEODA VENDOGNUS ABOEN ALALIWEN GREG BOZZA]
