sinatra-cometio
===============

* Node.js like Comet I/O plugin for Sinatra.
* http://shokai.github.com/sinatra-cometio


Installation
------------

    % gem install sinatra-cometio


Requirements
------------
* Ruby 1.8.7+ or 1.9.2+
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
CometIO.push :temperature, 35  # to all clients
CometIO.push :light, {:value => 150}, {:to => session_id} # to specific client
```

Client Side

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
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
io.push("chat", {name: "shokai", message: "hello"}); // client -> server
```

Server Side

```ruby
CometIO.on :chat do |data, session|
  puts "#{data['name']} : #{data['message']}  <#{session}>"
end
## => "shokai : hello  <12abcde345f6g7h8ijk>"
```

### On "connect" Event

Client Side

```javascript
io.on("connect", function(session){
  alert("connect!!");
});
```

Server Side

```ruby
CometIO.on :connect do |session|
  puts "new client <#{session}>"
end

CometIO.on :disconnect do |session|
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
event_id = CometIO.on :chat do |data, from|
  puts "#{data} - from#{from}"
end
CometIO.removeListener event_id
```

or

```ruby
CometIO.removeListener :chat  # remove all "chat" listener
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
    % export PORT=5000
    % export PID_FILE=/tmp/sinatra-cometio-test.pid
    % rake test


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request