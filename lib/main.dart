import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pour4me/custom_drink_page.dart';

import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pour4Me',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Pour4Me'),
      routes: <String, WidgetBuilder>{
        '/custom-drink': (BuildContext context) => CustomDrinkPage(title: 'Custom Drink')
      },
    );
  }
}

