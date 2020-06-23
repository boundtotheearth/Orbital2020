import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherGroups.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");

void runTests() {
  testWidgets("Groups UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroups(),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('Groups'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    //TODO: Listviews
    //expect(find.byType(ListView), findsOneWidget);
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