#!/usr/bin/env ruby

require 'bundler'

Bundler.require(:default)

# '../../lib',

paths = ['../lib', '../app'].map { File.expand_path _1, __dir__ }

$LOAD_PATH.unshift(*paths)
