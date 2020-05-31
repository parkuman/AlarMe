import 'dart:async';

import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:flutter/material.dart';

class NFCReader extends StatefulWidget {
  final Function snoozeFunction;
  NFCReader({this.snoozeFunction});

  @override
  _NFCReaderState createState() => _NFCReaderState();
}

class _NFCReaderState extends State<NFCReader> {
  bool _supportsNFC = false;
  bool _reading = false;
  StreamSubscription<NDEFMessage> _stream;

  @override
  void initState() {
    super.initState();
    // Check if the device supports NFC reading
    NFC.isNDEFSupported.then((bool isSupported) {
      setState(() {
        _supportsNFC = isSupported;
      });
    });

    setState(() {
      _reading = true;
      // Start reading using NFC.readNDEF()
      _stream = NFC
          .readNDEF(
        throwOnUserCancel: false,
      )
          .listen((NDEFMessage message) {
        print("read NDEF message: ${message.payload}");
        if (message.payload == "ensnooze") {
          _reading = false;
          widget.snoozeFunction();
          _stream?.cancel();
          Navigator.pop(context);
        }
      }, onError: (e) {
        print("error");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.only(top: 40.0, left: 10.0),
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          Center(
            child: !_supportsNFC
                ? Text("Please Turn on NFC")
                : Text(
                    "SCAN THE TAG MAN",
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
