import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherGroupView.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3");

void runTests() {
  testWidgets("Group View UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherGroupView(group: mockGroup),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text(mockGroup.name), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsOneWidget);

    Finder tabBarFinder = find.byType(TabBarView);
    expect(tabBarFinder, findsOneWidget);
    TabBarView tabBarView = tabBarFinder.evaluate().first.widget;
    expect(tabBarView.controller.index, 0);

    //TODO: Listviews

    //TODO: Test dragging
    //await tester.drag(find.byType(DropdownButtonFormField), Offset(-300, 0));
    await tester.tap(find.text('Students'));
    await tester.pump();

    expect(tabBarView.controller.index, 1);
    expect(find.text('Students'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsOneWidget);

    await tester.tap(find.text('Tasks'));

    expect(tabBarView.controller.index, 0);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets("Teacher Group View Drawer", (WidgetTester tester) async {
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