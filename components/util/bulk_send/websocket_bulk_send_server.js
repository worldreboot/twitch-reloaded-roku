WebSocketServer = require("ws").Server

ws = new WebSocketServer({port: 5000})
ws.on("connection", function (socket) {
    socket.on("error", function (error) {
        console.error(error);
    });
    console.log("Sending one thousand requests to client")
    for (var messageIndex = 0; messageIndex < 1000; messageIndex++)
        socket.send("How now brown cow. " + messageIndex)
    console.log("Finished sending")
});
console.log("Started bulk send websocket server on port 5000")
