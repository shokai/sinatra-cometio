require 'json'
require 'event_emitter'
require File.expand_path 'application', File.dirname(__FILE__)

class CometIO
  def self.channel
    @@channel ||= EM::Channel.new
  end
  
  def self.push(type, data)
    self.channel.push :type => type, :data => data
  end
end
EventEmitter.apply CometIO
