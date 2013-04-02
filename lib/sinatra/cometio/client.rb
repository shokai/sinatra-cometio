require File.expand_path '../../sinatra-cometio/version', File.dirname(__FILE__)
require 'event_emitter'
require 'httparty'
require 'json'

module Sinatra
  module CometIO
    class Client
      class Error < StandardError
      end

      include EventEmitter
      attr_reader :url, :session
      attr_accessor :timeout

      def initialize(url)
        raise ArgumentError, "invalid URL (#{url})" unless url.kind_of? String and url =~ /^https?:\/\/.+/
        @url = url
        @session = nil
        @running = false
        @timeout = 120
      end

      def push(type, data)
        post_data = {
          :session => @session,
          :events => [{:type => type, :data => data}]
        }
        begin
          res = HTTParty.post @url, :timeout => 10, :body => post_data
          emit :error, "CometIO push error" unless res.code == 200
        rescue StandardError, Timeout::Error => e
          emit :error, "CometIO push error"
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
              res = HTTParty.get "#{@url}?session=#{@session}", :timeout => @timeout
              unless res.code == 200
                self.emit :error, "CometIO get error"
                sleep 10
                next
              else
                data_arr = JSON.parse res.body
                data_arr = [data_arr] unless data_arr.kind_of? Array
                data_arr.each do |data|
                  self.emit data['type'], data['data']
                end
                next
              end
            rescue Timeout::Error, JSON::ParserError
              next
            rescue StandardError
              self.emit :error, "CometIO get error"
              sleep 10
              next
            end
          end
        end
      end

    end
  end
end
