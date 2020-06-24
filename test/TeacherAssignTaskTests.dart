import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherAssignTask.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3", students: Set());

Student mockStudent = Student(id: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2', name: "FarrellStu");

Task mockTask = Task(
  name: 'mockTask',
  description: 'mockDescription',
  createdByName: 'Farrell',
  createdById: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',
  dueDate: DateTime.now(),
  tags: ['tag1', 'tag2'],
);

void runTests() {
  testWidgets("Basic UI", (WidgetTester tester) async {
    MockDatabaseController mockDB = MockDatabaseController();

    await mockDB.initialiseNewStudent(mockStudent);
    await mockDB.teacherCreateGroup(teacherId: testUser.id, group: mockGroup);
    await mockDB.teacherAddStudentsToGroup(teacherId: testUser.id, group: mockGroup, students: [mockStudent]);
    await mockDB.teacherCreateTask(task: mockTask, group: mockGroup);

    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAssignTask(databaseController: mockDB, student: mockStudent, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Assign Task To Student'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.text('Assign Tasks'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('mockTask'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}