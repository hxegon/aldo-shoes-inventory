#!/usr/bin/env ruby

require_relative '../config/environment'

require 'bundler'
Bundler.require(:inv_consumer)

$LOAD_PATH.unshift(File.expand_path('app', __dir__))
