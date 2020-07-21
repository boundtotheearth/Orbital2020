import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:orbital2020/AddTaskToSchedule.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/FocusMode.dart';
import 'package:orbital2020/LeaderboardView.dart';
import 'package:orbital2020/StudentAddTask.dart';
import 'package:orbital2020/StudentMain.dart';
import 'package:orbital2020/StudentTaskView.dart';
import 'package:orbital2020/TeacherAddGroup.dart';
import 'package:orbital2020/TeacherAddStudentToGroup.dart';
import 'package:orbital2020/TeacherAddTask.dart';
import 'package:orbital2020/TeacherAssignStudent.dart';
import 'package:orbital2020/TeacherAssignTask.dart';
import 'package:orbital2020/TeacherGroupView.dart';
import 'package:orbital2020/TeacherGroups.dart';
import 'package:orbital2020/TeacherStudentView.dart';
import 'package:orbital2020/TeacherTaskView.dart';
import 'package:provider/provider.dart';

import 'LocalNotificationHandler.dart';
import 'Schedule.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final navigatorKey = GlobalKey<NavigatorState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  User user;
  DatabaseController db;
  Future<String> accountType;
  StreamSubscription iosSubscription;

  @override
  void initState() {
    user = Provider.of<User>(context, listen: false);
    db = Provider.of<DatabaseController>(context, listen: false);
    accountType = db.getAccountType(userId: user.id);
    _initFirebaseMessaging();
    LocalNotificationHandler.initLocalNotifications();
    super.initState();
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
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    // Get the token for this device
    String fcmToken = await _fcm.getToken();
    // Save it to Firestore
    if (fcmToken != null) {
      db.setToken(uid: user.id, token: fcmToken);
    }
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKey.currentState.maybePop(),
      child: FutureBuilder(
          future: accountType,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              user.accountType = snapshot.data;
              return Navigator(
                  key: navigatorKey,
                  initialRoute: user.accountType == 'student'
                      ? 'student_main'
                      : 'teacher_groups',
                  onGenerateRoute: (RouteSettings settings) {
                    WidgetBuilder builder;
                    switch (settings.name) {
                      case 'student_main':
                        builder = (_) => StudentMain();
                        break;
                      case 'student_addTask':
                        builder = (_) => StudentAddTask();
                        break;
                      case 'student_taskView':
                        builder = (_) => StudentTaskView(task: settings.arguments);
                        break;
                      case 'schedule':
                        builder = (_) => Schedule();
                        break;
                      case 'focus':
                        builder = (_) => FocusMode();
                        break;
                      case 'leaderboard':
                        builder = (_) => LeaderBoardView();
                        break;
                      case 'addSchedule':
                        Map<String, dynamic> arguments = settings.arguments;
                        builder = (_) =>
                            AddTaskToSchedule(scheduledDate: arguments['date'],
                              schedule: arguments['schedule'],);
                        break;
                      case 'teacher_groups':
                        builder = (_) => TeacherGroups();
                        break;
                      case 'teacher_addGroup':
                        builder = (_) => TeacherAddGroup();
                        break;
                      case 'teacher_addStudentToGroup':
                        builder = (_) =>
                            TeacherAddStudentToGroup(group: settings.arguments);
                        break;
                      case 'teacher_groupView':
                        builder =
                            (_) => TeacherGroupView(group: settings.arguments);
                        break;
                      case 'teacher_addTask':
                        builder =
                            (_) => TeacherAddTask(group: settings.arguments);
                        break;
                      case 'teacher_studentView':
                        Map<String, dynamic> arguments = settings.arguments;
                        builder = (_) =>
                            TeacherStudentView(student: arguments['student'],
                                group: arguments['group']);
                        break;
                      case 'teacher_taskView':
                        Map<String, dynamic> arguments = settings.arguments;
                        builder = (_) =>
                            TeacherTaskView(task: arguments['task'],
                                group: arguments['group']);
                        break;
                      case 'teacher_assignTask':
                        Map<String, dynamic> arguments = settings.arguments;
                        builder = (_) =>
                            TeacherAssignTask(student: arguments['student'],
                                group: arguments['group']);
                        break;
                      case 'teacher_assignStudent':
                        Map<String, dynamic> arguments = settings.arguments;
                        builder = (_) =>
                            TeacherAssignStudent(task: arguments['task'],
                                group: arguments['group']);
                        break;
                      default:
                        throw Exception("Invalid route: ${settings.name}");
                    }
                    return MaterialPageRoute(
                        builder: builder, settings: settings);
                  }
              );
            } else {
              return Scaffold(
                body: Container(),
              );
            }
          }
      ),
    );
  }

}