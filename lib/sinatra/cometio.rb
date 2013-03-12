require 'eventmachine'
require 'json'
require 'digest/md5'
require 'event_emitter'
require 'sinatra/streaming'
require File.expand_path '../sinatra-cometio/version', File.dirname(__FILE__)
require File.expand_path '../sinatra-cometio/options', File.dirname(__FILE__)
require File.expand_path '../sinatra-cometio/cometio', File.dirname(__FILE__)
require File.expand_path '../sinatra-cometio/application', File.dirname(__FILE__)

Sinatra.register Sinatra::CometIO
