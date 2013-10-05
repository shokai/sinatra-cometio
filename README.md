sinatra-cometio
===============
Comet component for [Sinatra RocketIO](https://github.com/shokai/sinatra-rocketio)

* Node.js like Comet I/O plugin for Sinatra.
* https://github.com/shokai/sinatra-cometio


Installation
------------

    % gem install sinatra-cometio


Requirements
------------
* Ruby 1.8.7 or 1.9.2 or 1.9.3 or 2.0.0
* Sinatra 1.3.0+
* EventMachine
* jQuery


Usage
-----

### Server --(Comet)--> Client

Server Side

```ruby
require 'sinatra'
require 'sinatra/cometio'
set :cometio, :timeout => 120, :post_interval => 1, :allow_crossdomain => false

run Sinatra::Application
```
```ruby
io = Sinatra::CometIO

io.push :temperature, 35  # to all clients
io.push :light, {:value => 150}, {:to => session_id} # to specific client
```

Client Side

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="<%= cometio_js %>"></script>
```
```javascript
var io = new CometIO().connect();

io.on("temperature", function(value){
  console.log("server temperature : " + value);
}); // => "server temperature : 35"
io.on("light", function(data){
  console.log("server light sensor : " + data.value);
}); // => "server light sensor : 150"
```


### Client --(Ajax)--> Server

Client Side

```javascript
io.on("connect", function(){
  io.push("chat", {name: "shokai", message: "hello"}); // client -> server
});
```

Server Side

```ruby
io.on :chat do |data, session|
  puts "#{data['name']} : #{data['message']}  <#{session}>"
end
## => "shokai : hello  <12abcde345f6g7h8ijk>"
```

### On "connect" Event

Client Side

```javascript
io.on("connect", function(session_id){
  alert("connect!! "+session_id);
});
```

Server Side

```ruby
io.on :connect do |session|
  puts "new client <#{session}>"
  io.push :hello, "hello new client!!"
end

io.on :disconnect do |session|
  puts "client disconnected <#{session}>"
end
```

### On "error" Event

Client Side

```javascript
io.on("error", function(err){
  console.error(err);
});
```

### Remove Event Listener

Server Side

```ruby
event_id = io.on :chat do |data, from|
  puts "#{data} - from#{from}"
end
io.removeListener event_id
```

or

```ruby
io.removeListener :chat  # remove all "chat" listener
```


Client Side

```javascript
var event_id = io.on("error", function(err){
  console.error("CometIO error : "err);
});
io.removeListener(event_id);
```

or

```javascript
io.removeListener("error");  // remove all "error" listener
```


Sample App
----------
chat app

- http://cometio-chat.herokuapp.com
- https://github.com/shokai/sinatra-cometio/tree/master/sample


Test
----

    % gem install bundler
    % bundle install

start server

    % rake test_server

run test

    % rake test


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request