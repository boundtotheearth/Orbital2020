import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherAssignStudent.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3");

Task mockTask = Task(
  name: 'mockTask',
  description: 'mockDescription',
  createdByName: 'Farrell',
  createdById: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',
  dueDate: DateTime.now(),
  tags: ['tag1', 'tag2'],
);

void runTests() {
  testWidgets("UI Test", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAssignStudent(task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('Students To Assign'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.text('Add Students'), findsOneWidget);
    //TODO: Listview
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}