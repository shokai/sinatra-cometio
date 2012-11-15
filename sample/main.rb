CometIO.on :chat do |data, from|
  puts "#{data['name']} : #{data['message']}  (from:#{from})"
  self.push :chat, data
end

CometIO.on :connect do |id|
  puts "new client <#{id}>"
  CometIO.push :chat, {:name => "system", :message => "new client <#{id}>"}
end

EM::defer do
  loop do
    CometIO.push :chat, :name => 'clock', :message => Time.now.to_s
    sleep 60
  end
end

get '/' do
  haml :index
end

get '/:source.css' do
  scss params[:source].to_sym
end
