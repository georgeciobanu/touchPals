var fs = require('fs');

var options = {
  key: fs.readFileSync('../certificates/arranged_marriage.key'),
  cert: fs.readFileSync('../certificates/arranged_marriage.crt')
};

console.log("Things are going well");
var app = require('https').createServer(options);

app.listen(8000);
var WebSocketServer = require('ws').Server;
var wss = new WebSocketServer({server: app});



// var WebSocketServer = require('ws').Server,
//     wss = new WebSocketServer({port:8000, host:'localhost'});
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

redisClient.on("message", function (channel, jsonMessage) {
   // for (var k in socketByToken) {
   //   console.log("Key: " + k + " Value: " + socketByToken[k]);
   // }
   console.log("Received message:");
   console.log(jsonMessage);
   
   // This is a potential security issue - JSON objects can contain code
   var parsedMessage = JSON.parse(jsonMessage);
   try {
     var token = parsedMessage.token;
     delete parsedMessage.token;
     console.log("About to send command: " + JSON.stringify(parsedMessage) + " to user with token: " + token);
     socketByToken[token].send(JSON.stringify(parsedMessage));

   } catch (err) {
     console.log(err);
     return;
   }
   
   console.log("Sent message: " + parsedMessage + " to user with token: " + token);
});

// redisClient.on("error", function (error) {
//   console.log("Some error happened to the redis client: " + error);
// }

   
  // app.listen(8000);
redisClient.subscribe("chats");
console.log("Connected to Redis...");

wss.on('close', function(ws) {
    console.log("Server: someone disconnected to me");
});

