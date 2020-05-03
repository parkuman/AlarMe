import 'dart:io';

class ClockServer {
  Socket _socket;
  String _name = "poop";

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

  String get name => _name;

  Socket get socket => _socket;
}
