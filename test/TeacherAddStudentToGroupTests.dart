import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/TeacherAddStudentToGroup.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
MockDatabaseController mockDB = MockDatabaseController();
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3", students: Set());
MaterialApp app = MaterialApp(
    home: MultiProvider(
      providers: [
        Provider<User>(
          create: (_) => testUser,
        ),
        Provider<DatabaseController>(
          create: (_) => mockDB,
        )
      ],
      child: TeacherAddStudentToGroup(group: mockGroup),
    )
);

void runTests() {
  testWidgets("Basic UI", (WidgetTester tester) async {

    await mockDB.initialiseNewStudent(Student(id: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2', name: 'testing student'));
    await mockDB.teacherCreateGroup(teacherId: testUser.id, group: mockGroup);

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Add Students To Group'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.text('Add Students'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('testing student'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}