import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/StudentTaskView.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "P6IYsnpoAZZTdmy2aLBHYHrMf6E2", name: "FarrellStu");
MockDatabaseController mockDB = MockDatabaseController();
MaterialApp getApp(TaskWithStatus task) {
  return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<User>(
            create: (_) => testUser,
          ),
          Provider<DatabaseController>(
            create: (_) => mockDB,
          )
        ],
        child: StudentTaskView(task: task,),
      )
  );
}
  Task selfTask = Task(
    name: 'selfTask',
    description: 'selfDescription',
    createdByName: 'FarrellStu',
    createdById: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2',
    dueDate: DateTime.now(),
    tags: ['tag1', 'tag2'],
  );

  TaskWithStatus selfTaskIncomplete = selfTask.addStatus(false, false);
  TaskWithStatus selfTaskCompleted = selfTask.addStatus(true, false);
  TaskWithStatus selfTaskVerified = selfTask.addStatus(true, true);

  Task teacherTask = Task(
    name: 'teacherTask',
    description: 'teacherDescription',
    createdByName: 'Farrell',
    createdById: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',
    dueDate: DateTime.now(),
    tags: ['tag1', 'tag2'],
  );

  TaskWithStatus teacherTaskIncomplete = teacherTask.addStatus(false, false);
  TaskWithStatus teacherTaskCompleted = teacherTask.addStatus(true, false);
  TaskWithStatus teacherTaskVerified = teacherTask.addStatus(true, true);

  void runTests() {
    testWidgets("Empty UI", (WidgetTester tester) async {

      await tester.pumpWidget(getApp(selfTaskIncomplete));

      expect(find.text('Created By'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Add Tag'), findsOneWidget);
      expect(find.byType(RaisedButton), findsOneWidget);
    });

    testWidgets("Full UI", (WidgetTester tester) async {

      await tester.pumpWidget(getApp(selfTaskIncomplete));

      expect(find.text(selfTaskIncomplete.name), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);
      expect(find.text(selfTaskIncomplete.description), findsOneWidget);
      expect(find.text(DateFormat('dd/MM/y').format(selfTaskIncomplete.dueDate)), findsOneWidget);
      for(String tag in selfTaskIncomplete.tags) {
        expect(find.text(tag), findsOneWidget);
      }
      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets("Completed UI", (WidgetTester tester) async {
      await tester.pumpWidget(getApp(selfTaskCompleted));

      expect(find.text('Waiting for Verification...'), findsOneWidget);
    });

    testWidgets("Verified UI", (WidgetTester tester) async {
      await tester.pumpWidget(getApp(selfTaskVerified));

      expect(find.text('Claim Reward'), findsOneWidget);
    });

    testWidgets("Editable UI", (WidgetTester tester) async {
      await tester.pumpWidget(getApp(selfTaskIncomplete));

      Finder nameFieldFinder = find.byKey(Key('name'));
      await tester.tap(nameFieldFinder);
      await tester.pump();
      TextFormField nameField = tester.widget(nameFieldFinder) as TextFormField;
      expect(nameField.enabled, isTrue);

      Finder descriptionFieldFinder = find.byKey(Key('description'));
      await tester.tap(descriptionFieldFinder);
      await tester.pump();
      TextFormField descriptionField = tester.widget(descriptionFieldFinder) as TextFormField;
      expect(descriptionField.enabled, isTrue);

      Finder dueFieldFinder = find.byKey(Key('due'));
      await tester.tap(dueFieldFinder);
      await tester.pump();
      TextFormField dueField = tester.widget(dueFieldFinder) as TextFormField;
      expect(dueField.enabled, isTrue);

      Finder tagsFieldFinder = find.byKey(Key('tags'));
      await tester.tap(tagsFieldFinder);
      await tester.pump();
      TextFormField tagsField = tester.widget(tagsFieldFinder) as TextFormField;
      expect(tagsField.enabled, isTrue);

      expect(find.byIcon(Icons.cancel), findsWidgets);
    });

    testWidgets("Not Editable UI", (WidgetTester tester) async {
      await tester.pumpWidget(getApp(teacherTaskIncomplete));

      Finder createdByFieldFinder = find.byKey(Key('created-by'));
      await tester.tap(createdByFieldFinder);
      await tester.pump();
      TextFormField createdByField = tester.widget(createdByFieldFinder) as TextFormField;
      expect(createdByField.enabled, isFalse);

      Finder nameFieldFinder = find.byKey(Key('name'));
      await tester.tap(nameFieldFinder);
      await tester.pump();
      TextFormField nameField = tester.widget(nameFieldFinder) as TextFormField;
      expect(nameField.enabled, isFalse);

      Finder descriptionFieldFinder = find.byKey(Key('description'));
      await tester.tap(descriptionFieldFinder);
      await tester.pump();
      TextFormField descriptionField = tester.widget(descriptionFieldFinder) as TextFormField;
      expect(descriptionField.enabled, isFalse);

      Finder dueFieldFinder = find.byKey(Key('due'));
      await tester.tap(dueFieldFinder);
      await tester.pump();
      TextFormField dueField = tester.widget(dueFieldFinder) as TextFormField;
      expect(dueField.enabled, isFalse);

      Finder tagsFieldFinder = find.byKey(Key('tags'));
      await tester.tap(tagsFieldFinder);
      await tester.pump();
      TextFormField tagsField = tester.widget(tagsFieldFinder) as TextFormField;
      expect(tagsField.enabled, isFalse);

      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets("Delete UI", (WidgetTester tester) async {

      await tester.pumpWidget(getApp(selfTaskIncomplete));
      expect(find.byType(PopupMenuButton), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(PopupMenuItem), findsOneWidget);
    });

    testWidgets("Date Picker Controls", (WidgetTester tester) async {

      await tester.pumpWidget(getApp(selfTaskIncomplete));

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
      await tester.pumpWidget(getApp(selfTaskIncomplete));

      await tester.enterText(find.byKey(Key('tags')), "tag3\n");
      await tester.pump();

      expect(find.text('tag3'), findsOneWidget);

      await tester.enterText(find.byKey(Key('tags')), "tag4");
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(find.text('tag4'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pump();

      expect(find.byType(Chip), findsNWidgets(2));

    });

    testWidgets("No Input Validation", (WidgetTester tester) async {

      await tester.pumpWidget(getApp(selfTaskIncomplete));

      Finder nameFieldFinder = find.byKey(Key('name'));
      await tester.tap(nameFieldFinder);
      await tester.pump();
      await tester.enterText(nameFieldFinder, '');

      Finder formFinder = find.byType(Form);
      for(Element formElement in formFinder.evaluate()) {
        Form form = formElement.widget;
        GlobalKey<FormState> formKey = form.key as GlobalKey<FormState>;
        formKey.currentState.validate();
      }

      await tester.pump();
      expect(find.text("Name Cannot be Empty!"), findsOneWidget);
      expect(find.byKey(Key('name')), findsOneWidget);
    });

    testWidgets("Valid Validation", (WidgetTester tester) async {
      await tester.pumpWidget(getApp(selfTaskIncomplete));

      Finder nameFieldFinder = find.byKey(Key('name'));
      await tester.tap(nameFieldFinder);
      await tester.pump();
      await tester.enterText(nameFieldFinder, 'newName');

      Finder descriptionFieldFinder = find.byKey(Key('description'));
      await tester.tap(descriptionFieldFinder);
      await tester.pump();
      await tester.enterText(descriptionFieldFinder, 'newDescription');

      Finder dueFieldFinder = find.byKey(Key('due'));
      await tester.tap(dueFieldFinder);
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pump();

      Finder tagsFieldFinder = find.byKey(Key('tags'));
      await tester.tap(tagsFieldFinder);
      await tester.pump();
      await tester.enterText(tagsFieldFinder, 'tag3\n');

      Finder formFinder = find.byType(Form);
      for(Element formElement in formFinder.evaluate()) {
        Form form = formElement.widget;
        GlobalKey<FormState> formKey = form.key as GlobalKey<FormState>;
        expect(formKey.currentState.validate(), isTrue);
      }
    });
  }