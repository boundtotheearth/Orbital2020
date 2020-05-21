import 'package:flutter/material.dart';
import 'package:orbital2020/StudentAddTask.dart';
import 'package:orbital2020/StudentMain.dart';
import 'package:orbital2020/TeacherAddGroup.dart';
import 'package:orbital2020/TeacherAddStudentToGroup.dart';
import 'package:orbital2020/TeacherAddTask.dart';
import 'package:orbital2020/TeacherAssignStudent.dart';
import 'package:orbital2020/TeacherAssignTask.dart';
import 'package:orbital2020/TeacherGroupView.dart';
import 'package:orbital2020/TeacherGroups.dart';
import 'package:orbital2020/TeacherStudentView.dart';
import 'package:orbital2020/TeacherTaskView.dart';
import 'package:orbital2020/main.dart';

class HomePage extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKey.currentState.maybePop(),
      child: Navigator(
        key: navigatorKey,
        initialRoute: 'main',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case 'main':
              builder = (_) => MyHomePage();
              break;
            case 'student_main':
              builder = (_) => StudentMain();
              break;
            case 'student_addTask':
              builder = (_) => StudentAddTask();
              break;
            case 'teacher_groups':
              builder = (_) => TeacherGroups(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',);
              break;
            case 'teacher_addGroup':
              builder = (_) => TeacherAddGroup(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',);
              break;
            case 'teacher_addStudentToGroup':
              builder = (_) => TeacherAddStudentToGroup(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1', group: settings.arguments,);
              break;
            case 'teacher_groupView':
              builder = (_) => TeacherGroupView(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',group: settings.arguments);
              break;
            case 'teacher_addTask':
              builder = (_) => TeacherAddTask(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1');
              break;
            case 'teacher_studentView':
              builder = (_) => TeacherStudentView(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',student: settings.arguments);
              break;
            case 'teacher_taskView':
              builder = (_) => TeacherTaskView();
              break;
            case 'teacher_assignTask':
              builder = (_) => TeacherAssignTask(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1', student: settings.arguments);
              break;
            case 'teacher_assignStudent':
              builder = (_) => TeacherAssignStudent(userId: 'CBHrubROTEaYnNwhrxpc3DBwhXx1', task: settings.arguments);
              break;
            default:
              throw Exception("Invalid route: ${settings.name}");
          }
          return MaterialPageRoute(builder: builder, settings: settings);

          }
      ),
    );
  }

}