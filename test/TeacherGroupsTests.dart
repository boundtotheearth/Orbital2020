import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherGroups.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");

void runTests() {
  testWidgets("Groups Basic UI", (WidgetTester tester) async {
    MockDatabaseController mockDB = MockDatabaseController();
    mockDB.teacherCreateGroup(
      teacherId: testUser.id,
      group: Group(
        name: "testing group",
        students: Set(),
      )
    );

    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroups(databaseController: mockDB,),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Groups'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('testing group'), findsOneWidget);
  });

  testWidgets("Teacher Groups Drawer", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroups(),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets("Teacher Groups Search", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroups(),
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