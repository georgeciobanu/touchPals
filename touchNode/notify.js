var redis = require("redis"),
       redisClient = redis.createClient(),
       msg_count = 0;

	var WebSocketServer = require('ws').Server
	  , wss = new WebSocketServer({port: 8000});
	
	wss.on('connection', function(ws) {
	    ws.on('message', function(message) {
	        console.log('received: %s', message);
	    });
		console.log("Someone connected:" + ws);
	    ws.send('something back');
	});

  redisClient.on("message", function (channel, message) {
     console.log("redisClient chat channel: "  + message);
     msg_count += 1;
  });

   
  // app.listen(8000);
  redisClient.subscribe("chats");
console.log("Started...");