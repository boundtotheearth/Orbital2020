import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherGroupView.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3", students: Set());

void runTests() {
  testWidgets("Basic UI", (WidgetTester tester) async {
    MockDatabaseController mockDB = MockDatabaseController();
    await mockDB.teacherCreateGroup(
      teacherId: testUser.id,
      group: mockGroup
    );

    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroupView(databaseController: mockDB, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text(mockGroup.name), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Students'), findsOneWidget);

    Finder tabBarFinder = find.byType(TabBarView);
    expect(tabBarFinder, findsOneWidget);
    TabBarView tabBarView = tabBarFinder.evaluate().first.widget;
    expect(tabBarView.controller.index, 0);
  });

  testWidgets("Tasks Tab UI", (WidgetTester tester) async {
    MockDatabaseController mockDB = MockDatabaseController();
    await mockDB.teacherCreateGroup(
        teacherId: testUser.id,
        group: mockGroup
    );
    await mockDB.teacherCreateTask(
        task: Task(
          name: 'testing task',
          createdById: testUser.id,
          createdByName: testUser.name
        ),
        group: mockGroup
    );

    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroupView(databaseController: mockDB, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField), findsOneWidget);

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('testing task'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets("Students Tab UI", (WidgetTester tester) async {
    MockDatabaseController mockDB = MockDatabaseController();
    await mockDB.teacherCreateGroup(
        teacherId: testUser.id,
        group: mockGroup
    );
    await mockDB.teacherAddStudentsToGroup(
      teacherId: testUser.id,
      group: mockGroup,
      students: [
        Student(
          name: "testing student"
        )
      ]
    );

    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroupView(databaseController: mockDB, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Students'));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('testing student'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets("Tab Swiping Transition", (WidgetTester tester) async {
    MockDatabaseController mockDB = MockDatabaseController();
    await mockDB.teacherCreateGroup(
        teacherId: testUser.id,
        group: mockGroup
    );
    await mockDB.teacherCreateTask(
        task: Task(
            name: 'testing task',
            createdById: testUser.id,
            createdByName: testUser.name
        ),
        group: mockGroup
    );
    await mockDB.teacherAddStudentsToGroup(
        teacherId: testUser.id,
        group: mockGroup,
        students: [
          Student(
              name: "testing student"
          )
        ]
    );

    print(mockDB.showDB());

    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroupView(databaseController: mockDB, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), Offset(-1000, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('testing student'), findsOneWidget);

    //TODO: Cannot test swiping the other way due to limitation of cloud_firestore_mock package.
    //Stream of snapshots only gives 1 value

//    await tester.fling(find.byType(ListView), Offset(1000, 0), 1000);
//    print(mockDB.showDB());
//    await tester.pumpAndSettle();
//
//    expect(find.text('testing task'), findsOneWidget);
  });

  testWidgets("Drawer UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroupView(group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets("Teacher Group View Search", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroupView(group: mockGroup),
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