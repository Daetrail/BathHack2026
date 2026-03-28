const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: '*',
    },
})

app.get('/', (req, res) => {
    console.log('Looking for: ', __dirname + '/index.html');
    res.sendFile(__dirname + '/index.html');
})

io.on('connection', (socket) => {
    console.log(`Client connected: ${socket.id}`);

    socket.on('chat message', (msg) => {
        console.log('Received: ', msg);
        socket.broadcast.emit('chat message', msg);
    });

    socket.on('disconnect', () => {
        console.log(`Client disconnected: ${socket.id}`);
    })
})

server.listen(3000, () => {
    console.log('Server running on http://localhost:3000');
})
