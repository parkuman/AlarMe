import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../main.dart';
import '../models/clock_server.dart';

import './connected_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Socket _socket;
  String _connectionText = "";
  String _lastAlarm = "";

  void _connect() {
    _socket = getIt<ClockServer>().socket;
    setState(() {
      _socket != null
          ? _connectionText =
              "Connected to clock @ ${_socket.address.address} port: ${_socket.port}"
          : _connectionText = "not connected";
    });
  }

  void _disconnect() {
    _socket.close();
    _socket = null;
  }

  void _readLastAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final lastHourKey = 'last_hour';
    final lastMinuteKey = 'last_minute';
    final lastHour = prefs.getInt(lastHourKey) ?? 0;
    final lastMinute = prefs.getInt(lastMinuteKey) ?? 0;
    setState(() {
      _lastAlarm = "${lastHour.toString().padLeft(2, '0')}:${lastMinute.toString().padLeft(2, '0')} ${lastHour > 12 ? "p.m." : "a.m."}";
    });

    print('last alarm HH/MM: $lastHour:$lastMinute');
  }

  @override
  void initState() {
    _connect();
    _readLastAlarm();
    super.initState();
  }

  @override
  void dispose() {
    _socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20.0),
            Text('$_connectionText'),
            Text('Last Alarm: $_lastAlarm'),
            SizedBox(height: 20.0),
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
            SizedBox(height: 20.0),
            _socket == null ? connectButton() : ConnectedPage(),
          ],
        ),
      ),
    );
  }

  Widget connectButton() {
    return Column(
      children: [
        SizedBox(height: 80.0),
        RaisedButton(
          onPressed: _connect,
          color: Colors.green,
          child: Container(
            width: 150.0,
            height: 100.0,
            alignment: Alignment.center,
            child: Text(
              "CONNECT",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontSize: 20.0),
            ),
          ),
        ),
      ],
    );
  }
}
