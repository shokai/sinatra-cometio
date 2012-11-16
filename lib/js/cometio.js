var CometIO = function(){
  this.url = "<%= cometio_url %>";
  this.session = null;
  var self = this;

  this.push = function(type, data){
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
    self.on("__session_id", function(session){
      self.session = session;
      self.emit("connect", self.session);
    });
    self.get();
    return self;
  };

  this.get = function(){
    $.ajax(
      {
        url : self.url,
        data : {session : self.session},
        success : function(data){
          if(data){
            self.emit(data.type, data.data);
          }
          self.get();
        },
        error : function(req, stat, e){
          self.emit("error", "CometIO get error");
          setTimeout(self.get, 10000);
        },
        complete : function(e){
        },
        type : "GET",
        dataType : "json",
        timeout : 60000
      }
    );
  };

  this.events = new Array();
  this.on = function(type, listener){
    if(typeof listener !== "function") return;
    var event_id = self.events.length > 0 ? 1 + self.events[self.events.length-1].id : 0
    self.events.push({
      id: event_id,
      type: type,
      listener: listener
    });
    return event_id;
  };

  this.emit = function(type, data){
    for(var i = 0; i < self.events.length; i++){
      var e = self.events[i];
      if(e.type == type) e.listener(data);
    }
  };

  this.removeListener = function(id_or_type){
    for(var i = self.events.length-1; i >= 0; i--){
      var e = self.events[i];
      switch(typeof id_or_type){
      case "number":
        if(e.id == id_or_type) self.events.splice(i,1);
        break
      case "string":
        if(e.type == id_or_type) self.events.splice(i,1);
        break
      }
    }
  };

};
