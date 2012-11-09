module Sinatra

  class Application

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
        puts "<#{sid}> comet"
        
        EM::add_timer 60 do
          s.close
          CometIO.channel.unsubscribe sid
        end
      end
    end

    post '/cometio/io' do
      type = params[:type]
      data = params[:data]
      begin
        if type.size > 0
          CometIO.emit type, data
        end
      rescue => e
        STDERR.puts e
      end
      'received'
    end
    
  end

end
