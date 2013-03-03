require 'rubygems'
require 'bundler'
Bundler.require
$stdout.sync = true
$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'sinatra'
require 'sinatra/cometio'
require File.dirname(__FILE__)+'/main'

run TestApp
