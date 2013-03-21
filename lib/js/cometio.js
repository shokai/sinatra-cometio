var CometIO = function(){
  new EventEmitter().apply(this);
  this.url = "<%= cometio_url %>";
  this.session = null;
  var running = false;
  var self = this;

  this.push = function(type, data){
    if(!self.session){
      self.emit("error", "CometIO not connected");
      return;
    }
    $.ajax(
      {
        url : self.url,
        data : {type : type, data : data, session : self.session},
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
