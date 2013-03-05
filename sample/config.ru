require 'rubygems'
require 'bundler/setup'
Bundler.require
if development?
  $stdout.sync = true
  require 'sinatra/reloader'
  $:.unshift File.expand_path '../lib', File.dirname(__FILE__)
end
require 'sinatra/cometio'
require File.dirname(__FILE__)+'/main'

set :haml, :escape_html => true
set :cometio, :timeout => 60

run Sinatra::Application
