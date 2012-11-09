require 'json'
require 'event_emitter'

module Sinatra

  class CometIO
    def self.channel
      @@channel ||= EM::Channel.new
    end

    def self.push(type, data)
      self.channel.push :type => type, :data => data
    end
  end
  EventEmitter.apply CometIO
  
  class Application

    get '/cometio.js' do
      @js ||= (
               js = nil
               File.open(File.expand_path '../js/cometio.js', File.dirname(__FILE__)) do |f|
                 js = f.read
               end
               js
               )
    end

    get '/cometio/io' do
      stream :keep_open do |s|
        sid = Sinatra::CometIO.channel.subscribe do |msg|
          begin
            s.write msg.to_json
            s.flush
            s.close
          rescue
            s.close
          end
          Sinatra::CometIO.channel.unsubscribe sid
        end
        puts "<#{sid}> comet"
        
        EM::add_timer 60 do
          s.close
          Sinatra::CometIO.channel.unsubscribe sid
        end
      end
    end

    post '/cometio/io' do
      type = params[:type]
      data = params[:data]
      begin
        if type.size > 0
          Sinatra::CometIO.emit type, data
        end
      rescue => e
        STDERR.puts e
      end
      'received'
    end
    
  end

end
