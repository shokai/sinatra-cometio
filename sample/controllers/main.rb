Sinatra::CometIO.on :chat do |data|
  Sinatra::CometIO.push :chat, data
end

before '/*.json' do
  content_type 'application/json'
end

get '/' do
  haml :index
end
