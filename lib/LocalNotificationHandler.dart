import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  static Future<void> scheduleNotification(DateTime startTime, DateTime endTime,
      String taskName, String scheduleId) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      scheduleId,
      'my channel name',
      'my channel description',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var _platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.schedule(
        0,
        "Schedule has started.",
        "Your schedule for the task: $taskName has started",
        startTime,
        _platformChannelSpecifics
    );

    await _flutterLocalNotificationsPlugin.schedule(
        0,
        "Schedule has ended.",
        "Your schedule for the task: $taskName has ended",
        endTime,
        _platformChannelSpecifics
    );
  }

  static Future<void> testScheduleNotification() async {
    print("start scheduling");
    DateTime startTime = DateTime.now().add(Duration(seconds: 30));
//    DateTime endTime = DateTime.now().add(Duration(seconds: 90));
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
    print("start first scheduling");
    await _flutterLocalNotificationsPlugin.schedule(
        0,
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

