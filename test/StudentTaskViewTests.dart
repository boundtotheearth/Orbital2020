import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/StudentTaskView.dart';
import 'package:provider/provider.dart';

User testUser = User(id: "P6IYsnpoAZZTdmy2aLBHYHrMf6E2", name: "FarrellStu");

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
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskIncomplete),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('Created By'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Due'), findsOneWidget);
    expect(find.text('Add Tag'), findsOneWidget);
    expect(find.byType(RaisedButton), findsOneWidget);
  });

  testWidgets("Full UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskIncomplete),
        )
    );
    await tester.pumpWidget(app);

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
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskCompleted),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('Waiting for Verification...'), findsOneWidget);
  });

  testWidgets("Verified UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskVerified),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('Claim Reward'), findsOneWidget);
  });

  testWidgets("Editable UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskIncomplete),
        )
    );
    await tester.pumpWidget(app);

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
  });

  testWidgets("Not Editable UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: teacherTaskIncomplete),
        )
    );
    await tester.pumpWidget(app);

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
  });

  testWidgets("Delete UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskIncomplete,),
        )
    );
    await tester.pumpWidget(app);
    expect(find.byType(PopupMenuButton), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
    expect(find.byType(PopupMenuItem), findsOneWidget);
  });

  testWidgets("Date Picker Controls", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskIncomplete,),
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
          child: StudentTaskView(task: selfTaskIncomplete,),
        )
    );
    await tester.pumpWidget(app);

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

  testWidgets("Empty Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskIncomplete),
        )
    );
    await tester.pumpWidget(app);

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
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: StudentTaskView(task: selfTaskIncomplete),
        )
    );
    await tester.pumpWidget(app);

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