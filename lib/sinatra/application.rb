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
      stream :keep_open do |s|
        session = params[:session].to_s.empty? ? CometIO.create_session : params[:session]
        CometIO.sessions[session][:stream] = s
        CometIO.emit :connect, session if params[:session].to_s.empty?

        unless CometIO.sessions[session][:queue].empty?
          begin
            s.write CometIO.sessions[session][:queue].shift.to_json
            s.flush
            s.close
          rescue
            s.close
          end
        end
        
        EM::add_timer 10 do
          begin
            s.write({:type => :cometio_heartbeat, :data => {:time => Time.now.to_s}}.to_json)
            s.flush
            s.close
          rescue
            s.close
          end
        end
      end
    end

    post '/cometio/io' do
      type = params[:type]
      data = params[:data]
      from = params[:session]
      CometIO.emit type, data, from if type.size > 0
      {:session => session, :type => type, :data => data}.to_json
    end
    
  end

end
