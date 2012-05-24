var WebSocketServer = require('ws').Server,
    wss = new WebSocketServer({port: 8000});
var socketByToken = {};

var redis = require("redis"),
       redisClient = redis.createClient();

wss.on('connection', function(ws) {

    console.log("Server: someone connected to me");
    // console.log('additional info:');
    // console.log(ws);
    ws.on('message', function(message) {
        console.log('received: %s', message);
        socketByToken[message] = this;
        console.log("Size of hash: " + socketByToken.length);
    });
});

redisClient.on("message", function (channel, message) {
   console.log("redisClient chat channel: "  + message);
   console.log("Size of hash: " + socketByToken.length);
   for (var k in socketByToken) {
     console.log("Key: " + k + " Value: " + socketByToken[k]);
   }
   socketByToken[message].send("You have mail!");
});

   
  // app.listen(8000);
redisClient.subscribe("chats");
console.log("Connected to Redis...");

wss.on('close', function(ws) {
    console.log("Server: someone disconnected to me");
});