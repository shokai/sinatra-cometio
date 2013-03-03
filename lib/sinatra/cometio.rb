require 'eventmachine'
require 'json'
require 'digest/md5'
require 'event_emitter'
require 'sinatra/streaming'
require File.expand_path '../sinatra-cometio/version', File.dirname(__FILE__)
require File.expand_path '../sinatra-cometio/options', File.dirname(__FILE__)
require File.expand_path '../sinatra-cometio/application', File.dirname(__FILE__)
Sinatra.register Sinatra::CometIO

class CometIO
  def self.sessions
    @@sessions ||= Hash.new{|h,session_id|
      h[session_id] = {
        :queue => [{:type => :__session_id, :data => session_id}],
        :stream => nil,
        :last => nil
      }
    }
  end

  def self.gc
    self.sessions.each do |id, s|
      next unless s[:last] and s[:last] < Time.now-CometIO.options[:xhr_interval]*2-10
      self.sessions.delete id rescue next
      self.emit :disconnect, id
    end
  end

  EM::defer do
    loop do
      self.gc
      sleep CometIO.options[:xhr_interval]+5
    end
  end

  def self.push(type, data, opt={})
    session_ids = opt[:to].to_s.empty? ? self.sessions.keys : [opt[:to]]
    session_ids.each do |id|
      s = self.sessions[id]
      if s[:queue].empty? and s[:stream] != nil
        begin
          s[:stream].write({:type => type, :data => data}.to_json)
          s[:stream].flush
          s[:stream].close
        rescue
          s[:stream].close
          s[:queue].push :type => type, :data => data
        end
      else
        s[:queue].push :type => type, :data => data
      end
    end
  end

  def self.create_session(ip_addr)
    Digest::MD5.hexdigest "#{Time.now.to_i}_#{Time.now.usec}_#{ip_addr}"
  end
end
EventEmitter.apply CometIO
