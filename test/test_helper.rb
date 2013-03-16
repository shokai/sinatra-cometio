require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'sinatra/cometio/client'
require File.expand_path 'app', File.dirname(__FILE__)

$:.unshift File.expand_path '../lib', File.dirname(__FILE__)

['SIGHUP', 'SIGINT', 'SIGKILL', 'SIGTERM'].each do |sig|
  Kernel.trap sig do
    App.stop
  end
end
