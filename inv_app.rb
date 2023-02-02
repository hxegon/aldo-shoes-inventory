#!/usr/bin/env ruby

require_relative './config/environment'

require 'bundler'
Bundler.require :inv_app

require 'sinatra'

get '/' do
  erb :index, locals: { time: Time.now }
end
