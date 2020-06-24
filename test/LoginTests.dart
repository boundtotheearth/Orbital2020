import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/Login.dart';

void runTests() {
  testWidgets("Login Form UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);
    //await tester.pumpAndSettle();

    expect(find.text("Garden of Focus"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
    expect(find.byType(RaisedButton), findsOneWidget);
    expect(find.text("Register here!"), findsOneWidget);
  });

  testWidgets("No Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    expect(find.text("Email cannot be empty!"), findsOneWidget);
    expect(find.text("Password cannot be empty!"), findsOneWidget);

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
  });

  testWidgets("Invalid Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);

    await tester.enterText(find.byKey(Key('email')), "abc");

    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    expect(find.text("Email format is invalid!"), findsOneWidget);

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
  });

  testWidgets("Valid Login Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);

    await tester.enterText(find.byKey(Key('email')), "abc@xyz.com");
    await tester.enterText(find.byKey(Key('password')), "abc");

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isTrue);
  });
}