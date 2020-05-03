import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:analog_clock/analog_clock.dart';
import 'dart:io';

import '../main.dart';
import '../models/clock_server.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Socket _socket;
  String _text = "";

  void _connect() {
    
    
    _socket = getIt<ClockServer>().socket;
    setState(() {
      _socket != null
          ? _text = "${_socket.address.address} - ${_socket.port}"
          : _text = "not connected";
    });
  }

  void _disconnect() {
    _socket.close();
    _socket = getIt<ClockServer>().socket;
    setState(() {
      _socket != null
          ? _text = "${_socket.address.address} - ${_socket.port}"
          : _text = "not connected";
    });
  }

  void _ledON() {
    _socket.write("ON\n");
  }

  void _ledOFF() {
    _socket.write("OFF\n");
  }

  void _alarmOn() {
    _socket.write("ALARM\n");
  }

  void _alarmOff() {
    _socket.write("SNOOZE\n");
  }

  @override
  void dispose() {
    _socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _connect();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnalogClock(
              width: MediaQuery.of(context).size.width - 150,
              height: MediaQuery.of(context).size.width - 150,
              showDigitalClock: false,
              tickColor: Colors.white,
              showAllNumbers: true,
              numberColor: Colors.white,
              hourHandColor: Colors.white,
              minuteHandColor: Colors.white,
              secondHandColor: Theme.of(context).accentColor,
            ),
            SizedBox(height: 50.0),
            Text('$_text'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: _connect,
                  child: Text(
                    "CONNECT",
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.white),
                  ),
                ),
                SizedBox(width: 5.0,),
                RaisedButton(
                  onPressed: _disconnect,
                  child: Text(
                    "DISCONNECT",
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.white),
                  ),
                ),
              ],
            ),
            RaisedButton(
              onPressed: _ledON,
              color: Colors.green,
              child: Text(
                "ON",
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
            RaisedButton(
              onPressed: _ledOFF,
              color: Colors.red,
              child: Text(
                "OFF",
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
            RaisedButton(
              onPressed: _alarmOn,
              color: Colors.purple,
              child: Text(
                "ALARM",
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
            RaisedButton(
              onPressed: _alarmOff,
              color: Colors.indigo,
              child: Text(
                "SNOOZE",
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
