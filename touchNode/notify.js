var WebSocketServer = require('ws').Server,
    wss = new WebSocketServer({port: 8000});
var socketByToken = {};

var redis = require("redis"),
       redisClient = redis.createClient();

wss.on('connection', function(ws) {

    console.log("Server: someone connected to me");
    // console.log('additional info:');
    // console.log(ws);
    ws.on('message', function(token) {
        console.log('received token: %s', token);
        // Extract token from message
        socketByToken[token] = this;
    });
    ws.on('error', function(error) {
        console.log('some error happened:' + error);
        console.log('A client may have called Close');
    });
    
});

redisClient.on("message", function (channel, message) {
   // for (var k in socketByToken) {
   //   console.log("Key: " + k + " Value: " + socketByToken[k]);
   // }
   console.log("Received message:");
   console.log(message);
   message = JSON.parse(message);
   console.log("About to send command: " + message.cmd + " to user with token: " + message.token);
   try {
     switch (message.cmd) {
       case "msg":
          socketByToken[message.token].send(message.text);
          break;
        case "found_match":
          socketByToken[message.token].send(message.partner_name);
          break;
        default:
          console.log("At the DMV getting a new license. Not implemented yet :-)");
     }

   } catch (err) {
     console.log(err);
     return;
   }
   
   console.log("Sent message: " + text + " to user with token: " + token);

});

   
  // app.listen(8000);
redisClient.subscribe("chats");
console.log("Connected to Redis...");

wss.on('close', function(ws) {
    console.log("Server: someone disconnected to me");
});