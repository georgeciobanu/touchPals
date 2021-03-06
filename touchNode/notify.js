var fs = require('fs');

// var options = {
//   key: fs.readFileSync('../certificates/arranged_marriage.key'),
//   cert: fs.readFileSync('../certificates/arranged_marriage.crt')
// };

console.log("Things are going well");
var app = require('http').createServer();

app.listen(8000);
var WebSocketServer = require('ws').Server;
var wss = new WebSocketServer({server: app});



// var WebSocketServer = require('ws').Server,
//     wss = new WebSocketServer({port:8000, host:'localhost'});
var socketByToken = {};

// Good to know about this potential bug - it occurs sometimes when
// the redis server is down and the client tries to reconnect before a certain number of tries
// https://github.com/mranney/node_redis/issues/20
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
	//this.close();
    });
    
});

redisClient.on("message", function (channel, jsonMessage) {
   console.log("Received message:");
   console.log(jsonMessage);
   
   // This is a potential security issue - JSON objects can contain code
   var parsedMessage = "";
   try {
     parsedMessage = JSON.parse(jsonMessage);
     var token = parsedMessage.token;
     delete parsedMessage.token;
     console.log("About to send command: " + JSON.stringify(parsedMessage) + " to user with token: " + token);
     socketByToken[token].send(JSON.stringify(parsedMessage));

   } catch (err) {
     console.log(err);
   }

   console.log("Sent message: " + parsedMessage + " to user with token: " + token);
});

redisClient.on("error", function (error) {
  console.log("Some error happened to the redis client: " + error);
});


redisClient.on("connect", function (maybe) {
  console.log("Connected to Redis...");
});

   
redisClient.subscribe("chats");


wss.on('close', function(ws) {
    console.log("Server: someone disconnected to me");
});

