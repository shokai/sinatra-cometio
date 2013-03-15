require 'rubygems'
$stdout.sync = true
$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'sinatra/base'
require 'sinatra/cometio'
require File.dirname(__FILE__)+'/main'

run TestApp
