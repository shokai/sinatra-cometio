var CometIO = function(){
  new EventEmitter().apply(this);
  this.url = "<%= cometio_url %>";
  this.session = null;
  var running = false;
  var self = this;
  var post_queue = [];

  var flush = function(){
    if(!running || post_queue.length < 1) return;
    var post_data = {
      session: self.session,
      events: post_queue
    };
    $.ajax(
      {
        url : self.url,
        data : post_data,
        success : function(data){
        },
        error : function(req, stat, e){
          self.emit("error", "CometIO push error");
        },
        complete : function(e){
        },
        type : "POST",
        dataType : "json",
        timeout : 10000
      }
    );
    post_queue = [];
  };
  setInterval(flush, <%= (CometIO.options[:post_interval]*1000).to_i %>);

  this.push = function(type, data){
    if(!running || !self.session){
      self.emit("error", "CometIO not connected");
      return;
    }
    post_queue.push({type: type, data: data})
  };

  this.connect = function(){
    if(running) return self;
    self.on("__session_id", function(session){
      self.session = session;
      self.emit("connect", self.session);
    });
    running = true;
    get();
    return self;
  };

  this.close = function(){
    running = false;
    self.removeListener("__session_id");
  };

  var get = function(){
    if(!running) return;
    $.ajax(
      {
        url : self.url,
        data : {session : self.session},
        success : function(data_arr){
          if(data_arr !== null || typeof data_arr !== "undefined" || !!data_arr.length){
            for(var i = 0; i < data_arr.length; i++){
              var data = data_arr[i];
              if(data) self.emit(data.type, data.data);
            }
          }
          get();
        },
        error : function(req, stat, e){
          self.emit("error", "CometIO get error");
          setTimeout(get, 10000);
        },
        complete : function(e){
        },
        type : "GET",
        dataType : "json",
        timeout : <%= (CometIO.options[:timeout]+10)*1000 %>
      }
    );
  };
};
