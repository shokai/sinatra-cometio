
get '/' do
  "sinatra-cometio v#{SinatraCometIO::VERSION}"
end

CometIO.on :connect do |session|
  puts "new client <#{session}>"
end

CometIO.on :disconnect do |session|
  puts "disconnect client <#{session}>"
end

CometIO.on :to_all do |data, from|
  puts from
  puts "to_all <#{from}> - #{data.to_json}"
  push :echo, data
end

CometIO.on :to_me do |data, from|
  puts "to_me <#{from}> - #{data.to_json}"
  push :echo, data, :to => from
end
