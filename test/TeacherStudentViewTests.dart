import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherStudentView.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3");

Student mockStudent = Student(id: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2', name: "FarrellStu");

void runTests() {
  testWidgets("UI Test", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherStudentView(student: mockStudent, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text(mockStudent.name), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsOneWidget);
    //TODO: Listview
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets("Remove Student UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherStudentView(student: mockStudent, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    //TODO
  });

  testWidgets("Drawer UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherStudentView(student: mockStudent, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets("Search UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherStudentView(student: mockStudent, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
  });
}