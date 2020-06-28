import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/TeacherAddGroup.dart';
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
      child: TeacherAddGroup(),
    )
);

void runTests() {
  testWidgets("Basic UI", (WidgetTester tester) async {

    await mockDB.initialiseNewStudent(Student(id: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2', name: 'testing student'));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('New Group'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.text('Add Students'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('testing student'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets("No Input Validation", (WidgetTester tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
    await tester.pump();
    
    expect(find.text("Name cannot be empty!"), findsOneWidget);
  });

  testWidgets("Valid Input Validation", (WidgetTester tester) async {

    await mockDB.initialiseNewStudent(Student(id: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2', name: 'testing student'));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('group-name')), 'abc');
    await tester.tap(find.text('testing student'));
    await tester.pumpAndSettle();

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isTrue);
  });

  testWidgets("Image Input Validation", (WidgetTester tester) async {
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
          child: TeacherAddGroup(),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    //TODO
  });
}