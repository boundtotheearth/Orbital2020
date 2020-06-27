import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/StudentMain.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

Type typeOf<T>() => T;
User testUser = User(id: "P6IYsnpoAZZTdmy2aLBHYHrMf6E2", name: "FarrellStu");
MockDatabaseController mockDB = MockDatabaseController();
MaterialApp app = MaterialApp (
    home: MultiProvider(
      providers: [
        Provider<User>(
          create: (_) => testUser,
        ),
        Provider<DatabaseController>(
          create: (_) => mockDB,
        )
      ],
      child: StudentMain(),
    )
);

void runTests() {
  testWidgets("Basic UI", (WidgetTester tester) async {

    mockDB.selfCreateAndAssignTask(
        task: Task(
          name: "testing task"
        ),
        student: Student(
          id: testUser.id,
          name: testUser.name
        ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text("Welcome FarrellStu"), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byType(UnityWidget), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(typeOf<ListView>()), findsOneWidget);
    expect(find.text('testing task'), findsOneWidget);
  });

  testWidgets("Drawer UI", (WidgetTester tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets("Search UI", (WidgetTester tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
  });
}