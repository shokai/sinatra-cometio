require 'json'
require 'digest/md5'
require 'event_emitter'
require 'sinatra/streaming'
require File.expand_path 'application', File.dirname(__FILE__)
require File.expand_path '../sinatra-cometio', File.dirname(__FILE__)

class CometIO
  def self.channel
    @@channel ||= EM::Channel.new
  end

  def self.sessions
    @@sessions ||= Hash.new{|h,k| h[k] = {:queue => []} }
  end
  
  def self.push(type, data, to=nil)
    unless to
      self.channel.push :type => type, :data => data
    else
      self.sessions[to.to_s][:queue].push :type => type, :data => data
    end
  end

  def self.create_session
    Digest::MD5.hexdigest "#{Time.now.to_i}_#{Time.now.usec}"
  end
end
EventEmitter.apply CometIO
