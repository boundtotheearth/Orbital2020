import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/StudentMain.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "P6IYsnpoAZZTdmy2aLBHYHrMf6E2", name: "FarrellStu");

void runTests() {
  testWidgets("Student Main UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentMain(),
        )
    );
    await tester.pumpWidget(app);
    await tester.pump(Duration(minutes: 1));

    expect(find.text("Welcome FarrellStu"), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byType(UnityWidget), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    //TODO: Test for listview
    //expect(find.byType(typeOf<ListView>()), findsOneWidget);
  });

  testWidgets("Student Main Drawer", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentMain(),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets("Student Main Search", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentMain(),
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