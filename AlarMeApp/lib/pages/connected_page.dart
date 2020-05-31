import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clock_server.dart';

import '../main.dart';
import './nfc_page.dart';

class ConnectedPage extends StatefulWidget {
  @override
  _ConnectedPageState createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;
  String _alarmTime = "";
  String lastAlarm = "";

  Socket _socket;

  Future<Null> selectTime(BuildContext context) async {
    _time = TimeOfDay.now();
    picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    setState(() {
      _time = picked;
      _alarmTime =
          "${_time.hourOfPeriod.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')} ${_time.period.index == 0 ? "a.m." : "p.m."}";
    });
  }

  void _ledOn() {
    _socket.write("ON\n");
  }

  void _ledOff() {
    _socket.write("OFF\n");
  }

  void _alarmOn() {
    _socket.write("ALARM\n");
  }

  void _alarmOff() {
    _socket.write("SNOOZE\n");
  }

  void _setAlarm({String hour, String minute}) {
    TimeOfDay currentTime = TimeOfDay.now();
    String currentHour = currentTime.hour.toString();
    String currentMinute = currentTime.minute.toString();
    _socket.write("*$hour:$minute");
    _socket.write("^$currentHour:$currentMinute");

    _displaySnackBar();

    _saveAlarm();
  }

  void _displaySnackBar() {
    final snackBar = SnackBar(
      content: Text(
          'Set an alarm for ${_time.hourOfPeriod.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')} ${_time.period.index == 0 ? "am" : "pm"}'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    );

    // Find the Scaffold in the widget tree and use
    // it to show a SnackBar.
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _saveAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final lastHourKey = 'last_hour';
    final lastMinuteKey = 'last_minute';
    final lastHour = _time.hour;
    final lastMinute = _time.minute;
    prefs.setInt(lastHourKey, lastHour);
    prefs.setInt(lastMinuteKey, lastMinute);
    print('saved alarm HH/MM: $lastHour:$lastMinute');
  }

  

  @override
  void initState() {
    setState(() {
      
      _socket = getIt<ClockServer>().socket;
      _alarmTime =
          "${_time.hourOfPeriod.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')} ${_time.period.index == 0 ? "am" : "pm"}";
    });
    super.initState();
  }

  @override
  void dispose() {
    _socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton(
            onPressed: () {
              selectTime(context);
            },
            child: Container(
              width: 250.0,
              height: 90.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm),
                  SizedBox(width: 10.0),
                  Text(
                    "$_alarmTime",
                    style:
                        TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          RaisedButton(
            onPressed: () {
              _setAlarm(hour: "${_time.hour}", minute: "${_time.minute}");
            },
            color: Colors.green,
            child: Container(
              width: 150.0,
              height: 60.0,
              alignment: Alignment.center,
              child: Text(
                "Set Alarm",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
            ),
          ),
          SizedBox(height: 30.0),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NFCReader(snoozeFunction: _alarmOff)));
            },
            color: Colors.red[200],
            child: Container(
              width: 150.0,
              height: 60.0,
              alignment: Alignment.center,
              child: Text(
                "SNOOZE",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ledControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RaisedButton(
          onPressed: _ledOn,
          color: Colors.green,
          child: Text(
            "ON",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
          ),
        ),
        SizedBox(width: 10.0),
        RaisedButton(
          onPressed: _ledOff,
          color: Colors.red,
          child: Text(
            "OFF",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget alarmControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RaisedButton(
          onPressed: _alarmOn,
          color: Colors.purple,
          child: Text(
            "ALARM",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
          ),
        ),
        SizedBox(width: 10),
        RaisedButton(
          onPressed: _alarmOff,
          color: Colors.indigo,
          child: Text(
            "SNOOZE",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
