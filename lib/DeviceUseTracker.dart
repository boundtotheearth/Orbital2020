//import 'dart:async';
//import 'package:flutter/material.dart';
//
//import 'package:background_fetch/background_fetch.dart';
//import 'package:orbital2020/Auth.dart';
//import 'package:orbital2020/DatabaseController.dart';
//
///// This "Headless Task" is run when app is terminated.
//generateBackgroundFetchHeadlessTask(String studentId) {
//  return (String taskId) async {
//    print('[BackgroundFetch] Headless event received.');
//    DatabaseController db = DatabaseController();
//    db.setStudentIdle(studentId);
//    BackgroundFetch.finish(taskId);
//  };
//
//}
//
//void backgroundFetchHeadlessTask(String taskId) async {
//  print('[BackgroundFetch] Headless event received.');
//  Auth auth = FirebaseAuthentication();
//  DatabaseController db = DatabaseController();
//  db.test();
//
//  await auth.getLoggedInUser().then((user) {
//    db.setStudentIdle(user.id);
//  });
//
//  BackgroundFetch.finish(taskId);
//}
//
//class DeviceUseTracker extends StatefulWidget {
//  final Widget child;
//  final String studentId;
//  DeviceUseTracker({Key key, @required this.child, @required this.studentId});
//
//  @override
//  _DeviceUseTrackerState createState() => new _DeviceUseTrackerState();
//}
//
//class _DeviceUseTrackerState extends State<DeviceUseTracker> {
//
//  @override
//  void initState() {
//    super.initState();
//    initPlatformState();
//    //BackgroundFetch.registerHeadlessTask(generateBackgroundFetchHeadlessTask(widget.studentId)).then((value) => print('headless success'));
//    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask).then((value) => print('headless success'));
//    //BackgroundFetch.start();
//    print("Setup completed!");
//  }
//
//  // Platform messages are asynchronous, so we initialize in an async method.
//  Future<void> initPlatformState() async {
//    // Configure BackgroundFetch.
//    BackgroundFetch.configure(BackgroundFetchConfig(
//        minimumFetchInterval: 15,
//        stopOnTerminate: false,
//        enableHeadless: true,
//        requiresDeviceIdle: false,
//    ), (String taskId) async {
//      // This is the fetch-event callback.
//      print("[BackgroundFetch] Event received $taskId");
//
//      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
//      // for taking too long in the background.
//      BackgroundFetch.finish(taskId);
//    }).then((int status) {
//      print('[BackgroundFetch] configure success: $status');
//    }).catchError((e) {
//      print('[BackgroundFetch] configure ERROR: $e');
//    });
//
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return widget.child;
//  }
//}