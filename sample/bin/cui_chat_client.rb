require 'rubygems'
require 'bundler/setup'
$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'sinatra/cometio/client'

name = `whoami`.strip || 'shokai'

client = Sinatra::CometIO::Client.new('http://localhost:5000/cometio/io').connect
puts "timeout:#{client.timeout}"

client.on :connect do |session|
  puts "connect!! (session_id:#{session})"
end

client.on :chat do |data|
  puts "<#{data['name']}> #{data['message']}"
end

client.on :error do |err|
  STDERR.puts err
end

loop do
  line = STDIN.gets.strip
  next if line.empty?
  client.push :chat, {:message => line, :name => name}
end
