
var Chat = function(url){
  this.url = url;
  var self = this;

  this.post = function(data){
    $.post(self.url, {cometio : {type : 'chat', data : data}});
  };

  this.start = function(){
    self.get();
  };

  this.on_get = null;

  this.get = function(){
    $.ajax(
      {
        url : self.url,
        success : function(data){
          if(data){
            if(self.on_get && typeof self.on_get == 'function') self.on_get(data);
          }
          self.get();
        },
        error : function(req, stat, e){
          setTimeout(self.get, 10000);
        },
        complete : function(e){
        },
        type : 'GET',
        dataType : 'json',
        timeout : 60000
      }
    );
  };
  
};
