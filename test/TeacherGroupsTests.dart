import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/TeacherAppDrawer.dart';
import 'package:orbital2020/TeacherGroups.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
MockDatabaseController mockDB = MockDatabaseController();
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
      child: TeacherGroups(),
    )
);

void runTests() {
  testWidgets("Basic UI", (WidgetTester tester) async {
    mockDB.teacherCreateGroup(
      teacherId: testUser.id,
      group: Group(
        name: "testing group",
        students: Set(),
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

  testWidgets("Drawer UI", (WidgetTester tester) async {

    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(TeacherAppDrawer), findsOneWidget);
  });

  testWidgets("Search UI", (WidgetTester tester) async {

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