require 'rubygems'
require 'sinatra'
require 'sinatra/base'
if development?
  $stdout.sync = true
  require 'sinatra/reloader'
  $:.unshift File.expand_path '../lib', File.dirname(__FILE__)
end
require 'sinatra/cometio'
require 'haml'
require 'sass'
require File.dirname(__FILE__)+'/main'

set :haml, :escape_html => true
set :cometio, :timeout => 60, :post_interval => 2, :allow_crossdomain => false

run ChatApp
