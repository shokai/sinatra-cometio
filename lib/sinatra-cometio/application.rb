module Sinatra
  module CometIO

    def self.registered(app)
      app.helpers Sinatra::Streaming
      app.helpers Sinatra::CometIO::Helpers

      app.get '/cometio/cometio.js' do
        content_type 'application/javascript'
        @js ||= ERB.new(Sinatra::CometIO.javascript).result(binding)
      end

      app.get '/cometio/io' do
        stream :keep_open do |s|
          session = params[:session].to_s.empty? ? CometIO.create_session(request.ip) : params[:session]
          CometIO.sessions[session][:stream] = s
          CometIO.sessions[session][:last] = Time.now
          CometIO.emit :connect, session if params[:session].to_s.empty?

          unless CometIO.sessions[session][:queue].empty?
            begin
              s.write CometIO.sessions[session][:queue].to_json
              s.flush
              s.close
            rescue
              s.close
            end
            CometIO.sessions[session][:queue] = []
          end

          EM::add_timer CometIO.options[:timeout] do
            begin
              s.write([{:type => :__heartbeat, :data => {:time => Time.now.to_i}}].to_json)
              s.flush
              s.close
            rescue
              s.close
            end
          end
        end
      end

      app.post '/cometio/io' do
        from = params[:session]
        halt 400, 'no session' if from.empty?
        events = params[:events]
        halt 400, 'no data' unless [Hash, Array].include? events.class
        events = events.keys.sort.map{|i| events[i] } if events.kind_of? Hash
        EM::defer do
          events.each do |e|
            next if !e['type'] or e['type'].empty?
            CometIO.emit e['type'], e['data'], from
          end
        end
        stream :keep_open do |s|
          begin
            s.write({:session => from, :success => true}.to_json)
            s.flush
            s.close
          rescue
            s.close
          end
        end
      end

    end
  end
end
