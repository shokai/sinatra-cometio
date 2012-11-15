require 'json'
require 'digest/md5'
require 'event_emitter'
require 'sinatra/streaming'
require File.expand_path 'application', File.dirname(__FILE__)
require File.expand_path '../sinatra-cometio', File.dirname(__FILE__)

class CometIO
  def self.sessions
    @@sessions ||= Hash.new{|h,session_id|
      h[session_id] = {
        :queue => [{:type => :set_session_id, :data => session_id}],
        :stream => nil
      }
    }
  end

  def self.push(type, data, to=nil)
    unless to
      self.sessions.each do |id,s|
        if s[:queue].empty?
          begin
            s[:stream].write({:type => type, :data => data}.to_json)
            s[:stream].flush
            s[:stream].close
          rescue
            s[:stream].class
            s[:queue].push :type => type, :data => data
          end
        else
          s[:queue].push :type => type, :data => data
        end
      end
    else
      self.sessions[to.to_s][:queue].push :type => type, :data => data
    end
  end

  def self.create_session
    Digest::MD5.hexdigest "#{Time.now.to_i}_#{Time.now.usec}"
  end
end
EventEmitter.apply CometIO
