$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra'
$stdout.sync = true if development?
require 'sinatra/reloader' if development?
require 'sinatra/cometio'
require 'sinatra/streaming'
require 'sinatra/content_for'
require 'yaml'
require 'json'
require 'haml'
require 'sass'
require File.dirname(__FILE__)+'/bootstrap'
Bootstrap.init :helpers, :controllers

set :haml, :escape_html => true

run Sinatra::Application
