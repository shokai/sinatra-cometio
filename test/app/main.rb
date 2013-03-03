pid_file = ENV['PID_FILE'] || "/tmp/sinatra-cometio-test-pid"
File.open(pid_file, "w+") do |f|
  f.write Process.pid.to_s
end

class TestApp < Sinatra::Application

  get '/' do
    "sinatra-cometio v#{Sinatra::CometIO::VERSION}"
  end

  CometIO.on :connect do |session|
    puts "new client <#{session}>"
  end

  CometIO.on :disconnect do |session|
    puts "disconnect client <#{session}>"
  end

  CometIO.on :broadcast do |data, from|
    puts from
    puts "broadcast <#{from}> - #{data.to_json}"
    push :broadcast, data
  end

  CometIO.on :message do |data, from|
    puts "message <#{from}> - #{data.to_json}"
    push :message, data, :to => data['to']
  end

end
