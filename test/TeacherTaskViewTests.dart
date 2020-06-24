import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/TeacherTaskView.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "CBHrubROTEaYnNwhrxpc3DBwhXx1", name: "Farrell");
Group mockGroup = Group(id: "AgRiWVNb2flktExYqpvN", name: "test Group 3", students: Set());

Task mockTask = Task(
  name: 'mockTask',
  description: 'mockDescription',
  createdByName: 'Farrell',
  createdById: 'CBHrubROTEaYnNwhrxpc3DBwhXx1',
  dueDate: DateTime.now(),
  tags: ['tag1', 'tag2'],
);

TaskWithStatus mockTaskIncomplete = mockTask.addStatus(false, false);
TaskWithStatus mockTaskCompleted = mockTask.addStatus(true, false);
TaskWithStatus mockTaskVerified = mockTask.addStatus(true, true);

void runTests() {
  testWidgets("Basic UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byType(PopupMenuButton), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Assigned'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

  });
  
  testWidgets("Empty Details UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Due'), findsOneWidget);
    expect(find.text('Add Tag'), findsOneWidget);
  });

  testWidgets("Full Details UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);

    expect(find.text(mockTask.name), findsOneWidget);
    expect(find.text(mockTask.description), findsOneWidget);
    expect(find.text(DateFormat('dd/MM/y').format(mockTask.dueDate)), findsOneWidget);
    for(String tag in mockTask.tags) {
      expect(find.text(tag), findsOneWidget);
    }
  });

  testWidgets("Assigned UI", (WidgetTester tester) async {
    MockDatabaseController mockDB = MockDatabaseController();
    await mockDB.teacherCreateGroup(
        teacherId: testUser.id,
        group: mockGroup
    );
    Student mockStudent = Student(id: 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2', name: "testing student");
    await mockDB.initialiseNewStudent(mockStudent);
    await mockDB.teacherAddStudentsToGroup(teacherId: testUser.id, group: mockGroup, students: [mockStudent]);
    await mockDB.teacherCreateTask(
        task: mockTask,
        group: mockGroup
    );
    await mockDB.teacherAssignStudentsToTask([mockStudent], mockTask);
    print(mockDB.showDB());

    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(databaseController: mockDB, task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.text('Assigned'));
    await tester.pumpAndSettle();

    expect(find.byType(ProgressIndicator), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text("testing student"), findsOneWidget);
    //TODO
  });

  testWidgets("Editable UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
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

  testWidgets("Delete UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    expect(find.byType(PopupMenuButton), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
    expect(find.byType(PopupMenuItem), findsOneWidget);
  });

  testWidgets("Drawer UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets("Search UI", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
        )
    );
    await tester.pumpWidget(app);
    //TODO
  });

  testWidgets("Date Picker Controls", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
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
          child: TeacherTaskView(task: mockTask, group: mockGroup),
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

  testWidgets("No Input Validation", (WidgetTester tester) async {
    MaterialApp app = MaterialApp (
        home: Provider<User>(
          create: (_) => testUser,
          child: TeacherTaskView(task: mockTask, group: mockGroup),
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
          child: TeacherTaskView(task: mockTask, group: mockGroup),
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