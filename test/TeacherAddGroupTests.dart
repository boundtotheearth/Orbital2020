import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherAddGroup.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");

void runTests() {
  testWidgets("UI Test", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddGroup(),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('New Group'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.text('Add Students'), findsOneWidget);
    //TODO: Listview
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets("No Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddGroup(),
        )
    );
    await tester.pumpWidget(app);

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
    await tester.pump();
    
    expect(find.text("Name cannot be empty!"), findsOneWidget);
  });

  testWidgets("Valid Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddGroup(),
        )
    );
    await tester.pumpWidget(app);
    await tester.enterText(find.byKey(Key('group-name')), 'abc');
    //TODO: Add students also

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isTrue);
  });

  testWidgets("Image Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherAddGroup(),
        )
    );
    await tester.pumpWidget(app);
    //TODO
  });
}