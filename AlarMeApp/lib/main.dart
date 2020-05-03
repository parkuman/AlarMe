import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get_it/get_it.dart';

import './pages/home_page.dart';
import './models/clock_server.dart';

GetIt getIt = GetIt.instance;

void main() {
  getIt.registerSingleton<ClockServer>(ClockServer());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: HomePage(
        title: 'AlarMe',
      ),
    );
  }
}
