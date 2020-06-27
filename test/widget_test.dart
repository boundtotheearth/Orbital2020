// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'LoginTests.dart' as LoginTests;
import 'SignupTests.dart' as SignupTests;
import 'StudentMainTests.dart' as StudentMainTests;
import 'StudentAddTaskTests.dart' as StudentAddTaskTests;
import 'StudentTaskViewTests.dart' as StudentTaskViewTests;
import 'TeacherGroupsTests.dart' as TeacherGroupsTests;
import 'TeacherGroupViewTests.dart' as TeacherGroupViewTests;
import 'TeacherTaskViewTests.dart' as TeacherTaskViewTests;
import 'TeacherStudentViewTests.dart' as TeacherStudentViewTests;
import 'TeacherAddGroupTests.dart' as TeacherAddGroupTests;
import 'TeacherAddStudentToGroupTests.dart' as TeacherAddStudentToGroupTests;
import 'TeacherAssignStudentTests.dart' as TeacherAssignStudentsTests;
import 'TeacherAssignTaskTests.dart' as TeacherAssignTaskTests;
import 'TeacherAddTaskTests.dart' as TeacherAddTaskTests;
import 'ScheduleTest.dart' as ScheduleTest;
import 'AddScheduleTest.dart' as AddScheduleTest;

Type typeOf<T>() => T;

void main() {
  setUp(() {
    WidgetsBinding.instance.renderView.configuration =  new TestViewConfiguration(size: const Size(1080.0, 2340.0));
  });

  group("Login Tests", () {
    LoginTests.runTests();
  });
  group("Signup Tests", () {
    SignupTests.runTests();
  });

  group("Student Main Tests", () {
    StudentMainTests.runTests();
  });
  group("Student Add Task Tests", () {
    StudentAddTaskTests.runTests();
  });
  group("Student Task View Tests", () {
    StudentTaskViewTests.runTests();
  });
  group("Schedule Tests", () {
    ScheduleTest.runTests();
  });
  group("Add to Schedule Tests", () {
    AddScheduleTest.runTests();
  });

  group("Teacher Groups Tests", () {
    TeacherGroupsTests.runTests();
  });
  group("Teacher Group View Tests", () {
    TeacherGroupViewTests.runTests();
  });
  group("Teacher Task View Tests", () {
    TeacherTaskViewTests.runTests();
  });
  group("Teacher Student View Tests", () {
    TeacherStudentViewTests.runTests();
  });
  group("Teacher Add Group Tests", () {
    TeacherAddGroupTests.runTests();
  });
  group("Teacher Add Student To Group Tests", () {
    TeacherAddStudentToGroupTests.runTests();
  });
  group("Teacher Assign Students Tests", () {
    TeacherAssignStudentsTests.runTests();
  });
  group("Teacher Assign Task Tests", () {
    TeacherAssignTaskTests.runTests();
  });
  group("Teacher Add Task Tests", () {
    TeacherAddTaskTests.runTests();
  });
}
