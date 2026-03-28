socket.join('room-abc');
io.to('room-abc').emit('update', {data: 123});