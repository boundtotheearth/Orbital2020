import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/Login.dart';

Type typeOf<T>() => T;
void runTests() {
  testWidgets("Signup Form UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);
    //Navigate to signup screen
    await tester.tap(find.text("Register here!"));
    await tester.pump();

    expect(find.text("I am a:"), findsOneWidget);
    expect(find.byType(typeOf<RadioListTile<AccountType>>()), findsNWidgets(2));
    expect(find.text("Student"), findsOneWidget);
    expect(find.text("Full Name"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
    expect(find.text("Confirm Password"), findsOneWidget);
    expect(find.byType(RaisedButton), findsOneWidget);
    //expect(find.text("Login here!"), findsOneWidget);
  });

  testWidgets("No Signup Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);
    //Navigate to signup screen
    await tester.tap(find.text("Register here!"));
    await tester.pump();
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    expect(find.text("Name cannot be empty!"), findsOneWidget);
    expect(find.text("Email cannot be empty!"), findsOneWidget);
    expect(find.text("Password cannot be empty!"), findsOneWidget);

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
  });

  testWidgets("Invalid Signup Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);
    //Navigate to signup screen
    await tester.tap(find.text("Register here!"));
    await tester.pump();

    await tester.enterText(find.byKey(Key('email')), 'abc');
    await tester.enterText(find.byKey(Key('password')), 'abc');

    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    expect(find.text("Email format is invalid!"), findsOneWidget);
    expect(find.text("Password must be at least 8 characters long!"), findsOneWidget);

    await tester.enterText(find.byKey(Key('password')), 'abcdefghijk');

    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    expect(find.text('Passwords do not match!'), findsOneWidget);

    expect(find.text('Password must have at least one special character!'), findsOneWidget);

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isFalse);
  });

  testWidgets("Valid Signup Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
      home: LoginPage(),
    );
    await tester.pumpWidget(app);
    //Navigate to signup screen
    await tester.tap(find.text("Register here!"));
    await tester.pump();

    await tester.enterText(find.byKey(Key('name')), 'abc');
    await tester.enterText(find.byKey(Key('email')), "abc@xyz.com");
    await tester.enterText(find.byKey(Key('password')), "abcdefghijk*");
    await tester.enterText(find.byKey(Key('confirm-password')), "abcdefghijk*");

    Finder formFinder = find.byType(Form);
    Form formWidget = tester.widget(formFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;
    expect(formKey.currentState.validate(), isTrue);
  });
}