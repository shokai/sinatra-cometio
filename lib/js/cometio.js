var CometIO = function(){
  this.url = "<%= cometio_url %>";
  var self = this;

  this.push = function(type, data){
    $.post(self.url, {type : type, data : data});
  };

  this.connect = function(){
    self.get();
    return self;
  };

  this.get = function(){
    $.ajax(
      {
        url : self.url,
        success : function(data){
          if(data){
            self.emit(data.type, data.data);
          }
          self.get();
        },
        error : function(req, stat, e){
          setTimeout(self.get, 10000);
        },
        complete : function(e){
        },
        type : "GET",
        dataType : "json",
        timeout : 10000
      }
    );
  };

  this.events = new Array();
  this.on = function(type, listener){
    if(typeof listener === "function"){
      self.events.push({type: type, listener: listener});
    }
  };

  this.emit = function(type, data){
    for(var i = 0; i < self.events.length; i++){
      var e = self.events[i];
      if(e.type == type) e.listener(data);
    }
  };

};
