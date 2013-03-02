require File.expand_path '../../sinatra-cometio/version', File.dirname(__FILE__)
require 'event_emitter'
require 'httparty'
require 'json'

class CometIO
  class Client
    class Error < StandardError
    end

    include EventEmitter
    attr_reader :url, :session

    def initialize(url)
      raise ArgumentError, "invalid URL (#{url})" unless url.kind_of? String and url =~ /^https?:\/\/.+/
      @url = url
      @session = nil
      @running = false
    end

    def push(type, data)
      begin
        res = HTTParty.post @url, :body => {:type => type, :data => data, :session => @session}
      rescue StandardError, Timeout::Error => e
        emit :error, "CometIO push error"
      ensure
        emit :error, "CometIO push error" unless res.code == 200
      end
    end

    def connect
      return self if @running
      self.on :__session_id do |session|
        @session = session
        self.emit :connect, @session
      end
      @running = true
      get
      return self
    end

    def close
      @running = false
      self.remove_listener :__session_id
    end

    private
    def get
      Thread.new do
        while @running do
          begin
            res = HTTParty.get "#{@url}?session=#{@session}", :timeout => 60000
            unless res.code == 200
              self.emit :error, "CometIO get error"
              sleep 10
              next
            else
              data = JSON.parse res.body
              self.emit data['type'], data['data']
            end
          rescue StandardError, Timeout::Error
            self.emit :error, "CometIO get error"
            sleep 10
            next
          end
        end
      end
    end

  end
end
