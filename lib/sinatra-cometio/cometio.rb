module Sinatra
  module CometIO

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
        next unless s[:last] and s[:last] < Time.now-CometIO.options[:timeout]*2-10
        self.sessions.delete id rescue next
        self.emit :disconnect, id
      end
    end

    EM::defer do
      loop do
        self.gc
        sleep CometIO.options[:timeout]+5
      end
    end

    def self.push(type, data, opt={})
      if opt.include? :to
        return unless self.sessions.include? opt[:to]
        s = self.sessions[opt[:to]]
        if s[:queue].empty? and s[:stream] != nil
          begin
            s[:stream].write([{:type => type, :data => data}].to_json)
            s[:stream].flush
            s[:stream].close
          rescue
            s[:stream].close
            s[:queue].push :type => type, :data => data
          end
          s[:stream] = nil
        else
          s[:queue].push :type => type, :data => data
        end
        return
      end
      self.sessions.keys.each do |id|
        push type, data, :to => id
      end
    end

    def self.create_session(ip_addr)
      Digest::MD5.hexdigest "#{Time.now.to_i}_#{Time.now.usec}_#{ip_addr}"
    end

  end
end
EventEmitter.apply Sinatra::CometIO
