WebSocketServer = require("ws").Server

ws = new WebSocketServer({port: 5000})
ws.on("connection", function (socket) {
    socket.on("message", function (message) {
        console.log(message)
        socket.send(message)
    });
    socket.on("error", function (error) {
        console.error(error);
    });
});
console.log("Started echo websocket server on port 5000")
