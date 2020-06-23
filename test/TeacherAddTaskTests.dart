import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherAddTask.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3");

void runTests() {
  testWidgets("Teacher Add Task UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddTask(group: mockGroup,),
        )
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text("Add Task"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
    expect(find.text('Due', skipOffstage: false), findsOneWidget);
    expect(find.text('Add Tag'), findsOneWidget);
    expect(find.byType(RaisedButton), findsWidgets);
  });

  testWidgets("No Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddTask(group: mockGroup,),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    expect(find.text("Name cannot be empty!"), findsOneWidget);

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
  });

  testWidgets("Invalid Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddTask(group: mockGroup,),
        )
    );
    await tester.pumpWidget(app);

    await tester.enterText(find.byKey(Key('due')), 'abc');
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    expect(find.text("Invalid date format!"), findsOneWidget);

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
  });

  testWidgets("Date Picker UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddTask(group: mockGroup,),
        )
    );
    await tester.pumpWidget(app);

    await tester.tap(find.byKey(Key('due')));
    await tester.pump();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text("SELECT DATE"), findsOneWidget);
    expect(find.text("CANCEL"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
  });

  testWidgets("Date Picker Controls", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddTask(group: mockGroup,),
        )
    );
    await tester.pumpWidget(app);

    await tester.tap(find.byKey(Key('due')));
    await tester.pump();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsNothing);

    await tester.tap(find.byKey(Key('due')));
    await tester.pump();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text("CANCEL"), findsOneWidget);

    await tester.tap(find.text('CANCEL'));
    await tester.pump();

    expect(find.byType(CalendarDatePicker), findsNothing);
  });

  testWidgets("Add Tag Controls", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddTask(group: mockGroup,),
        )
    );
    await tester.pumpWidget(app);

    await tester.enterText(find.byKey(Key('tags')), "tag1\n");
    await tester.pump();

    expect(find.text('tag1'), findsOneWidget);

    await tester.enterText(find.byKey(Key('tags')), "tag2");
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(find.text('tag2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cancel).first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.cancel).first);
    await tester.pump();

    expect(find.byType(Chip), findsNothing);

  });

  testWidgets("Valid Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddTask(group: mockGroup,),
        )
    );
    await tester.pumpWidget(app);

    await tester.enterText(find.byKey(Key('name')), "abc");
    await tester.enterText(find.byKey(Key('description')), "abc");
    await tester.tap(find.byKey(Key('due')));
    await tester.pump();
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.enterText(find.byKey(Key('tags')), "abc\n");
    await tester.pump();

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isTrue);
  });
}