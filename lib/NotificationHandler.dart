import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/LocalNotificationHandler.dart';
import 'package:provider/provider.dart';

import 'HomePage.dart';

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  User _user;
  DatabaseController _db;

  StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();
    _db = Provider.of<DatabaseController>(context, listen: false);
    _user = Provider.of<User>(context, listen: false);
    _initFirebaseMessaging();
    LocalNotificationHandler.initLocalNotifications();

  }

  void _initFirebaseMessaging() {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message['data']['title']),
            content: Text(message['data']['body']),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
//        _showNotification(message["data"]);
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
//        _showNotification(message["data"]);
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

      // Save it to Firestore
    if (fcmToken != null) {
      _db.setToken(uid: _user.id, token: fcmToken);
    }

  }
}


