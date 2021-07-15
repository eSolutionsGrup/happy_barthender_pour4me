import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'pour_for_me_mqtt_client.dart';

class PourCommand {
  String command;
  String drink;

  PourCommand(this.command, this.drink);

  Map<String, String> toJson() => { 'command': command, 'drink': drink };
}

class EndCommand {
  String command = 'finish';
  Map<String, int> drinkDuration = new HashMap();

  EndCommand();

  Map<String, dynamic> toJson() => { 'command': command, 'drink_durations': drinkDuration };
}

class CustomDrinkPage extends StatefulWidget {
  CustomDrinkPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CustomDrinkPageState createState() => _CustomDrinkPageState();
}

class _CustomDrinkPageState extends State<CustomDrinkPage> {
  Duration _startPress;
  EndCommand _endCommand = new EndCommand();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Text(
              "Create your drink",
              style: Theme.of(context).textTheme.headline3,
            ),
            Listener(
                child: Column(
                      children: [
                        Image.asset('images/whiskey.jpg',height: 150,),
                        Text('Whiskey')
                      ]
                    ),
                onPointerDown: (PointerDownEvent pointerDownEvent) {
                  print('Pointer down');
                  Pour4MeMqttClient.publish(context, '/pour4me/custom-drink', jsonEncode(PourCommand('dose_start', 'whiskey')));
                  _startPress = pointerDownEvent.timeStamp;

                },
                onPointerUp: (PointerUpEvent pointerUpEvent) {
                  final durationInMillis = (pointerUpEvent.timeStamp - _startPress).inMilliseconds;
                  print('You tapped up after: $durationInMillis');
                  Pour4MeMqttClient.publish(context, '/pour4me/custom-drink', jsonEncode(PourCommand('dose_stop', 'whiskey')));
                  _endCommand.drinkDuration.update('whiskey', (value) => value + durationInMillis, ifAbsent: () => durationInMillis);
                }
            ),
            Listener(
                child: Column(
                    children: [
                      Image.asset('images/vodka.jpg',height: 150,),
                      Text('Vodka')
                    ]
                ),
                onPointerDown: (PointerDownEvent pointerDownEvent) {
                  print('Pointer down');
                  Pour4MeMqttClient.publish(context, '/pour4me/custom-drink', jsonEncode(PourCommand('dose_start', 'vodka')));
                  _startPress = pointerDownEvent.timeStamp;

                },
                onPointerUp: (PointerUpEvent pointerUpEvent) {
                  final durationInMillis = (pointerUpEvent.timeStamp - _startPress).inMilliseconds;
                  print('You tapped up after: $durationInMillis');
                  Pour4MeMqttClient.publish(context, '/pour4me/custom-drink', jsonEncode(PourCommand('dose_stop', 'vodka')));
                  _endCommand.drinkDuration.update('vodka', (value) => value + durationInMillis, ifAbsent: () => durationInMillis);
                }
            ),
            RaisedButton(
                child: Text("Finish"),
                onPressed: () {
                  print("Pressed Finish");
                  Pour4MeMqttClient.publish(context, "/pour4me/custom-drink", jsonEncode(_endCommand));
                  Navigator.pop(context);
                }),
            Pour4MeMqttClient.subscribeToMqttConnectedFeed(),
            Pour4MeMqttClient.subscribeToMqttStatusFeed(),
          ],
        ),
      ),
    );
  }
}