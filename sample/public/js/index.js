var io = new CometIO().connect();

io.on("chat", function(data){
  var m = $("<li>").text(data.name + " : " +data.message);
  $("#chat #timeline").prepend(m);
});

io.on("connect", function(session){
  console.log("connect!! "+session);
  $("#chat #btn_send").click(post);
  $("#chat #message").keydown(function(e){
    if(e.keyCode == 13) post();
  });
});

io.on("error", function(err){
  console.error(err);
});

var post = function(){
  var name = $("#chat #name").val();
  var message = $("#chat #message").val();
  if(message.length < 1) return;
  io.push("chat", {name: name, message: message});
  $("#chat #message").val("");
};
