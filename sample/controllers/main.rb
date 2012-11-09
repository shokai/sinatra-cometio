CometIO.on :chat do |data|
  self.push :chat, data
end

CometIO.on :connect do |id|
  puts "comet <#{id}> connect."
end

EM::defer do
  loop do
    CometIO.push :chat, {:name => 'clock', :message => Time.now.to_s}
    sleep 60
  end
end

get '/' do
  haml :index
end
