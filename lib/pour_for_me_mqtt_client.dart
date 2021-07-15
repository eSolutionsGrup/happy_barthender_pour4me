import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Pour4MeMqttClient {
  static Pour4MeMqttClient _instance;

  MqttClient client;

  static var _statusFeed = BehaviorSubject<String>();
  static var _connectedFeed = BehaviorSubject<bool>();

  String previousTopic;
  bool bAlreadySubscribed = false;

  static Pour4MeMqttClient getInstance() {
    if(_instance == null) {
      return new Pour4MeMqttClient();
    }
    return _instance;
  }

  static Future<bool> subscribe(BuildContext context, String topic) async {
    Pour4MeMqttClient instance = getInstance();
    if (await instance._connectToClient(context) == true) {
      instance._subscribe(topic);
    }

    return true;
  }

  static Future<void> publish(BuildContext context, String topic, String value) async {
    Pour4MeMqttClient instance = getInstance();
    // Connect to the client if we haven't already
    if (await instance._connectToClient(context) == true) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(value);
      instance.client.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
    }
  }

  void _setCallbacks() {
    print('SETTING CALLBACKS');
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<MqttClient> _login(BuildContext context) async {
    client = MqttServerClient('broker.hivemq.com', 'pour4me');
    _setCallbacks();
    // Turn on mqtt package's logging while in test.
    client.logging(on: false);
    final MqttConnectMessage connMess = MqttConnectMessage()
    // .authenticateAs(connectJson['username'], connectJson['key'])
        .withClientIdentifier('pour4me')
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);
    print('mqtt client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
    /// never send malformed messages.
    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXCEPTION::client exception - $e');
      client.disconnect();
      client = null;
      return client;
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('mqtt client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print('mqtt client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      client = null;
    }
    return client;
  }

  /// The subscribed callback
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
    this.bAlreadySubscribed = true;
    this.previousTopic = topic;
    _statusFeed.add('subscribed');
  }

  /// The unsolicited disconnect callback
  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    _statusFeed.add('disconnected');
    _connectedFeed.add(false);
  }

  /// The successful connect callback
  void _onConnected() {
    print('OnConnected client callback - Client connection was successful');
    _statusFeed.add('connected');
    _connectedFeed.add(true);
  }

  Future _subscribe(String topic) async {
    // for now hardcoding the topic
    if (this.bAlreadySubscribed == true) {
      client.unsubscribe(this.previousTopic);
    }
    print('Subscribing to the topic $topic');
    client.subscribe(topic, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The payload is a byte buffer, this will be specific to the topic
      print("Got message $pt");
      print('Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      return pt;
    });
  }

  Future<bool> _connectToClient(BuildContext context) async {
    if (client != null &&
        client.connectionStatus.state == MqttConnectionState.connected) {
      print('already logged in');
    } else {
      client = await _login(context);
      if (client == null) {
        return false;
      }
    }
    return true;
  }

  static Widget subscribeToMqttStatusFeed() {
    return StreamBuilder(
        stream: _statusFeed.stream,
        initialData: 'no data available',
        builder: (context, snapshot) {
          return Text('MQTT status: ${snapshot.data}');
        });
  }

  static Widget subscribeToMqttConnectedFeed() {
    return StreamBuilder(
        stream: _connectedFeed.stream,
        initialData: false,
        builder: (context, snapshot) {
          return Text('MQTT connected: ${snapshot.data}');
        });
  }
}
