module Sinatra::CometIO

  def cometio=(options)
    CometIO.options = options
  end

  def cometio
    CometIO.options
  end

  helpers do
    def cometio_js
      "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/cometio/cometio.js"
    end

    def cometio_url
      "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/cometio/io"
    end
  end

  get '/cometio/cometio.js' do
    content_type 'application/javascript'
    @js ||= (
             js = ''
             Dir.glob(File.expand_path '../js/*.js', File.dirname(__FILE__)).each do |i|
               File.open(i) do |f|
                 js += f.read
               end
             end
             ERB.new(js).result(binding)
             )
  end

  get '/cometio/io' do
    stream :keep_open do |s|
      session = params[:session].to_s.empty? ? CometIO.create_session(request.ip) : params[:session]
      CometIO.sessions[session][:stream] = s
      CometIO.sessions[session][:last] = Time.now
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

      EM::add_timer CometIO.options[:xhr_interval] do
        begin
          s.write({:type => :__heartbeat, :data => {:time => Time.now.to_i}}.to_json)
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
    CometIO.emit type, data, from if type.to_s.size > 0
    {:session => from, :type => type, :data => data}.to_json
  end

end
