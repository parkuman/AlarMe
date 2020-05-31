import 'dart:io';

class ClockServer {
  Socket _socket;

  ClockServer() {
    connect();
  }

  void connect() async {
    try {
      _socket = await Socket.connect('192.168.2.170', 80);
      print("Connected");
    } catch (error) {
      print('Server Connection Error: $error');
    }

    print(_socket.toString());
  }

  Socket get socket => _socket;
}
