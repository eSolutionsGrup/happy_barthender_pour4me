import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pour4me/pour_for_me_mqtt_client.dart';

class Cocktail {
  final String cocktail;

  Cocktail(this.cocktail);

  Map<String, dynamic> toJson() => {'cocktail': cocktail};
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curve;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    curve = CurvedAnimation(parent: controller, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Choose your drink",
              style: Theme.of(context).textTheme.headline3,
            ),
            RaisedButton(
                child: Text(
                  'Cuba Libre',
                ),
                onPressed: () {
                  print("Cuba Libre");
                  Pour4MeMqttClient.publish(context, "/pour4me", jsonEncode(Cocktail("cuba_libre")));
                }),
            RaisedButton(
                child: Text("Salted Caramel"),
                onPressed: () {
                  print("Salted Caramel");
                  Pour4MeMqttClient.publish(
                      context, "/pour4me", jsonEncode(Cocktail("salted_caramel")));
                }),
            RaisedButton(
                child: Text("Cognac"),
                onPressed: () {
                  print("Cognac");
                  Pour4MeMqttClient.publish(context, "/pour4me", jsonEncode(Cocktail("cognac")));
                }),
            RaisedButton(
                child: Text("Espresso Martini"),
                onPressed: () {
                  print("Espresso Martini");
                  Pour4MeMqttClient.publish(context, "/pour4me",
                      jsonEncode(Cocktail("espresso_martini")));
                }),
            RaisedButton(
                child: Text("White Russian"),
                onPressed: () {
                  print("White Russia");
                  Pour4MeMqttClient.publish(
                      context, "/pour4me", jsonEncode(Cocktail("white_russian")));
                }),
            Pour4MeMqttClient.subscribeToMqttConnectedFeed(),
            Pour4MeMqttClient.subscribeToMqttStatusFeed(),
            RaisedButton(
                child: Text("/drinks"),
                onPressed: () {
                  Navigator.of(context).pushNamed('/drink');
                }),
            RaisedButton(
                child: Text("Custom Drink"),
                onPressed: () {
                  Navigator.of(context).pushNamed('/custom-drink');
                }),
          ],
        ),
      ),
    );
  }
}
