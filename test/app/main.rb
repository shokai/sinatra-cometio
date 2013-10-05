class TestApp < Sinatra::Base
  register Sinatra::CometIO

  get '/' do
    "sinatra-cometio v#{Sinatra::CometIO::VERSION}"
  end

  Sinatra::CometIO.on :connect do |session|
    puts "new client <#{session}>"
  end

  Sinatra::CometIO.on :disconnect do |session|
    puts "disconnect client <#{session}>"
  end

  Sinatra::CometIO.on :broadcast do |data, from|
    puts from
    puts "broadcast <#{from}> - #{data.to_json}"
    push :broadcast, data
  end

  Sinatra::CometIO.on :message do |data, from|
    puts "message <#{from}> - #{data.to_json}"
    push :message, data, :to => data['to']
  end

end
