module Sinatra

  class Application

    helpers do
      def cometio_js
        "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/cometio/cometio.js"
      end
    end

    get '/cometio/cometio.js' do
      content_type 'application/javascript'
      @js ||= (
               js = nil
               File.open(File.expand_path '../js/cometio.js', File.dirname(__FILE__)) do |f|
                 js = f.read
               end
               cometio_url = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/cometio/io"
               ERB.new(js).result(binding)
               )
    end

    get '/cometio/io' do
      session = params[:session]
      stream :keep_open do |s|
        sid = CometIO.channel.subscribe do |msg|
          begin
            s.write msg.to_json
            s.flush
            s.close
          rescue
            s.close
          end
          CometIO.channel.unsubscribe sid
        end
        if session.to_s.empty?
          session = CometIO.create_session
          begin
            s.write({:type => :set_session_id, :data => session}.to_json)
            s.flush
            s.close
          rescue
            s.close
          end
          CometIO.emit :connect, session
        end
        
        EM::add_timer 10 do
          begin
            s.write({:type => :cometio_heartbeat, :data => {:time => Time.now.to_s}}.to_json)
            s.flush
            s.close
          rescue
            s.close
          end
          CometIO.channel.unsubscribe sid
        end
      end
    end

    post '/cometio/io' do
      type = params[:type]
      data = params[:data]
      session = params[:session]
      CometIO.emit type, data if type.size > 0
      {:session => session, :type => type, :data => data}.to_json
    end
    
  end

end
