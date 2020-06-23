import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherAssignTask.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3");

Student mockStudent = Student(id: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2', name: "FarrellStu");

void runTests() {
  testWidgets("UI Test", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAssignTask(student: mockStudent, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('Assign Task To Student'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.text('Assign Tasks'), findsOneWidget);
    //TODO: Listview
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}