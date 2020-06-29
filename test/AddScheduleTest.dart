import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/AddTaskToSchedule.dart';
import 'package:orbital2020/DataContainers/ScheduleDetails.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "I2MnlPlUYsX6ufy77OGT5gkLrBH3", name: "Vanessa Wong");
MockDatabaseController mockDB = MockDatabaseController();
Task mockTask = Task(
//  id: '1234567',
  name: 'mockTask',
  description: 'mockDescription',
  createdByName: testUser.name,
  createdById: testUser.id,
  dueDate: DateTime.now(),
  tags: ['tag1', 'tag2'],
);
MaterialApp getApp({DateTime date, ScheduleDetails details}) {
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
        child: AddTaskToSchedule(scheduledDate: date, schedule: details,),
      )
  );
}

void runTests() {

  DateTime today = DateTime.now();
  DateTime todayNoTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime beforeToday = DateTime.now().subtract(Duration(days: 1));
  DateTime afterToday = DateTime.now().add(Duration(days: 1));


  
  testWidgets("General Page UI for adding", (WidgetTester tester) async {

    await tester.pumpWidget(getApp(date: today));

    expect(find.byType(DropdownButtonFormField), findsOneWidget);
    expect(find.widgetWithText(TextFormField, ""), findsNWidgets(2));
    expect(find.byKey(Key("date")), findsOneWidget);
    expect(find.byKey(Key("start")), findsOneWidget);
    expect(find.byKey(Key("end")), findsOneWidget);

    await tester.tap(find.byKey(Key("date")));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsNothing);

    await tester.tap(find.byKey(Key("start")));
    await tester.pump();
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    await tester.tap(find.byKey(Key("end")));
    await tester.pump();
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    expect(find.byType(RaisedButton), findsOneWidget);
    expect(find.text("Add to Schedule"), findsOneWidget);
  });

  testWidgets("Display selected date if it is after today", (WidgetTester tester) async {

    await tester.pumpWidget(getApp(date: today));
    expect(find.text(DateFormat("y-MM-dd").format(today)), findsOneWidget);
  });

  testWidgets("Display today's date if selected date is before today", (WidgetTester tester) async {
    await tester.pumpWidget(getApp(date: beforeToday));
    expect(find.text(DateFormat("y-MM-dd").format(today)), findsOneWidget);
  });

  testWidgets("General Page UI for editing", (WidgetTester tester) async {
    Student student = Student(id: testUser.id, name: testUser.name);
    await mockDB.initialiseNewStudent(student);
    await mockDB.selfCreateAndAssignTask(student: student, task: mockTask);

    ScheduleDetails schedule = ScheduleDetails(
      scheduledDate: todayNoTime.add(Duration(days: 1)),
      startTime: afterToday,
      endTime: afterToday.add(Duration(minutes: 1))
    );

    await tester.pumpWidget(getApp(date: afterToday, details: schedule));

    expect(find.widgetWithText(TextFormField, DateFormat("y-MM-dd").format(schedule.scheduledDate)), findsOneWidget);
    expect(find.widgetWithText(TextFormField, DateFormat("HH:mm").format(schedule.startTime)), findsOneWidget);
    expect(find.widgetWithText(TextFormField, DateFormat("HH:mm").format(schedule.endTime)), findsOneWidget);

    await tester.tap(find.byKey(Key("date")));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsNothing);

    await tester.tap(find.byKey(Key("start")));
    await tester.pump();
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    await tester.tap(find.byKey(Key("end")));
    await tester.pump();
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    expect(find.byType(RaisedButton), findsOneWidget);
    expect(find.text("Delete from Schedule"), findsOneWidget);
  });

  testWidgets("General Page UI for viewing", (WidgetTester tester) async {

    ScheduleDetails schedule = ScheduleDetails(
        taskId: mockTask.id,
        scheduledDate: beforeToday,
        startTime: beforeToday,
        endTime: beforeToday.add(Duration(minutes: 1))
    );

    await tester.pumpWidget(getApp(date: beforeToday, details: schedule));
    await tester.pump();
    expect(find.byType(DropdownButtonFormField), findsOneWidget);
    expect(find.widgetWithText(TextFormField, DateFormat("y-MM-dd").format(schedule.scheduledDate)), findsOneWidget);
    expect(find.widgetWithText(TextFormField, DateFormat("HH:mm").format(schedule.startTime)), findsOneWidget);
    expect(find.widgetWithText(TextFormField, DateFormat("HH:mm").format(schedule.endTime)), findsOneWidget);

    await tester.tap(find.byKey(Key("date")));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsNothing);

    await tester.tap(find.byKey(Key("start")));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    await tester.tap(find.byKey(Key("end")));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    expect(find.byType(RaisedButton), findsOneWidget);
    expect(find.text("Delete from Schedule"), findsOneWidget);
  });

  testWidgets(("Validate schedule date"), (WidgetTester tester) async {
    await tester.pumpWidget(getApp(date: todayNoTime));
    Finder dateField = find.byKey(Key("date"));
    await tester.enterText(dateField, "");
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Scheduled Date cannot be empty!"), findsOneWidget);
    await tester.enterText(dateField, "hello");
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Invalid date format! Should be y-MM-dd."), findsOneWidget);
    await tester.enterText(dateField, "2020-01-01");
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Schedule date cannot be before today!"), findsOneWidget);
  });

  testWidgets("Validate start time input", (WidgetTester tester) async {
    await tester.pumpWidget(getApp(date: todayNoTime));
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Start Time cannot be empty!"), findsOneWidget);
    Finder startField = find.byKey(Key("start"));
    await tester.enterText(startField, "hello");
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Invalid time format! Should be HH:mm"), findsOneWidget);
    await tester.enterText(startField, DateFormat("HH:mm").format(today.subtract(Duration(minutes: 1))));
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Start Time must be later than current time!"), findsOneWidget);
  });

  testWidgets("Validate end time input", (WidgetTester tester) async {
    await tester.pumpWidget(getApp(date: todayNoTime));
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("End Time cannot be empty!"), findsOneWidget);
    Finder endField = find.byKey(Key("end"));
    await tester.enterText(endField, "hello");
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Invalid time format! Should be HH:mm"), findsOneWidget);
    Finder startField = find.byKey(Key("start"));
    await tester.enterText(startField, "14:00");
    await tester.enterText(endField, "13:00");
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("End Time must be after Start Time"), findsOneWidget);
  });



}