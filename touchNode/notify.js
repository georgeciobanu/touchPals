var redis = require("redis"),
       redisClient = redis.createClient(),
       msg_count = 0;

var io = require('socket.io').listen(8000);




  io.sockets.on('connection', function (socket) {
  console.log(socket);
  console.log("client connected");
    // socket.emit('news', 'world');
   socket.on('my other event', function (data) {
     console.log(data);
   });
   socket.on('disconnect', function () {
     console.log("user disconnected");
   });
   
  });

  redisClient.on("message", function (channel, message) {
     console.log("redisClient chat channel: "  + message);
     msg_count += 1;
  });

   
  // app.listen(8000);
  redisClient.subscribe("chats");