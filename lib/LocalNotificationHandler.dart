import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'DatabaseController.dart';

class LocalNotificationHandler {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initLocalNotifications() {
    var initializationSettingsAndroid = new AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);

  }

  static Map<String, int> scheduleNewNotification(DateTime startTime, DateTime endTime,
      String taskName) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'my channel id',
      'my channel name',
      'my channel description',
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var _platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    int startId = Random().nextInt(pow(2,31));
    int endId = Random().nextInt(pow(2,31));
    _flutterLocalNotificationsPlugin.schedule(
        startId,
        "Schedule has started.",
        "Your schedule for the task '$taskName' has started",
        startTime,
        _platformChannelSpecifics
    );

    _flutterLocalNotificationsPlugin.schedule(
        endId,
        "Schedule has ended.",
        "Your schedule for the task '$taskName' has ended",
        endTime,
        _platformChannelSpecifics
    );
    return {"startId" : startId, "endId" : endId};
  }

  static void replaceNotification(DateTime startTime, DateTime endTime,
      String taskName, int startId, int endId) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'my channel id',
      'my channel name',
      'my channel description',
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var _platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    _flutterLocalNotificationsPlugin.schedule(
        startId,
        "Schedule has started.",
        "Your schedule for the task '$taskName' has started",
        startTime,
        _platformChannelSpecifics
    );

    _flutterLocalNotificationsPlugin.schedule(
        endId,
        "Schedule has ended.",
        "Your schedule for the task '$taskName' has ended",
        endTime,
        _platformChannelSpecifics
    );
  }

  static void cancelNotification(int startId, int stopId, DateTime startTime, DateTime endTime) {
    if (DateTime.now().isBefore(startTime)) {
      _flutterLocalNotificationsPlugin.cancel(startId);
      _flutterLocalNotificationsPlugin.cancel(stopId);
    } else if (DateTime.now().isBefore(endTime)) {
      _flutterLocalNotificationsPlugin.cancel(stopId);
    }
  }

  static Future<void> testScheduleNotification() async {
    print("start scheduling");
    DateTime startTime = DateTime.now().add(Duration(seconds: 60));
//    DateTime endTime = DateTime.now().add(Duration(seconds: 90));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1234567',
      'my channel name',
      'my channel description',
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var _platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    print("start first scheduling");
    int id = Random().nextInt(pow(2,31));
    await _flutterLocalNotificationsPlugin.schedule(
        id,
        "Schedule has started.",
        "Your schedule for the task: Do work has started",
        startTime,
        _platformChannelSpecifics
    );
//    print("start second scheduling");
//    await _flutterLocalNotificationsPlugin.schedule(
//        1,
//        "Schedule has ended.",
//        "Your schedule for the task: Do work has ended",
//        endTime,
//        _platformChannelSpecifics
//    );
    print("end scheduling");
    await Future.delayed(Duration(seconds: 10));
    print("start unscheduling");
    await _flutterLocalNotificationsPlugin.cancel(id);
    print("unscheduling completed");
  }

  static Future<void> unscheduleNotification(DateTime startTime, DateTime endTime, String taskName, String scheduleId) async {

  }

  static Future<void> testUnscheduleNotification() async {
    print("start unscheduling");
    await _flutterLocalNotificationsPlugin.cancel(0);
    print("canceled start");
//    await _flutterLocalNotificationsPlugin.cancel(1);
//    print("canceled end");
    print("unscheduling completed");
  }
}

