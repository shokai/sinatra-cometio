module Sinatra
  module CometIO

    def cometio=(options)
      CometIO.options = options
    end

    def cometio
      CometIO.options
    end

    def self.registered(app)
      app.helpers Sinatra::CometIO::Helpers

      app.get '/cometio/cometio.js' do
        content_type 'application/javascript'
        @js ||= (
                 js = ''
                 Dir.glob(File.expand_path '../js/*.js', File.dirname(__FILE__)).sort.each do |i|
                   File.open(i) do |f|
                     js += f.read
                   end
                 end
                 ERB.new(js).result(binding)
                 )
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
        type = params[:type]
        data = params[:data]
        from = params[:session]
        EM::defer do
          CometIO.emit type, data, from unless type.to_s.empty?
        end
        stream :keep_open do |s|
          begin
            s.write({:session => from, :type => type, :data => data}.to_json)
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
