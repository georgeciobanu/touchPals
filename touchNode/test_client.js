var WebSocket = require('ws');
var ws = new WebSocket('wss://localhost:8000');
ws.on('open', function() {
    console.log("connected");
    ws.send('WXpw8wRzRnVYWQqE8oYx');
});
ws.on('message', function(data, flags) {
    // flags.binary will be set if a binary data is received
    // flags.masked will be set if the data was masked
    console.log('meow: received:' + data);
});