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
    expect(find.byType(TextFormField), findsNWidgets(3));

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
    expect(find.text(DateFormat("dd/MM/y").format(today)), findsOneWidget);
  });

  testWidgets("Display today's date if selected date is before today", (WidgetTester tester) async {
    await tester.pumpWidget(getApp(date: beforeToday));
    expect(find.text(DateFormat("dd/MM/y").format(today)), findsOneWidget);
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
//    expect(find.byType(DropdownButtonFormField), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));

    expect(find.text(DateFormat("dd/MM/y").format(schedule.scheduledDate)), findsOneWidget);
    await tester.tap(find.byKey(Key("date")));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsNothing);

    expect(find.text(DateFormat("HH:mm").format(schedule.startTime)), findsOneWidget);
    await tester.tap(find.byKey(Key("start")));
    await tester.pump();
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    expect(find.text(DateFormat("HH:mm").format(schedule.endTime)), findsOneWidget);
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
    expect(find.byType(TextFormField), findsNWidgets(3));

    expect(find.text(DateFormat("dd/MM/y").format(schedule.scheduledDate)), findsOneWidget);
    await tester.tap(find.byKey(Key("date")));
    await tester.pump();
    expect(find.byType(CalendarDatePicker), findsNothing);


    expect(find.text(DateFormat("HH:mm").format(schedule.startTime)), findsOneWidget);
    await tester.tap(find.byKey(Key("start")));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    expect(find.text(DateFormat("HH:mm").format(schedule.endTime)), findsOneWidget);
    await tester.tap(find.byKey(Key("end")));
    await tester.pump();
    expect(find.text("OK"), findsNothing);

    expect(find.byType(RaisedButton), findsOneWidget);
    expect(find.text("Delete from Schedule"), findsOneWidget);
  });

  testWidgets("Validate start time must be after current time", (WidgetTester tester) async {

    await tester.pumpWidget(getApp(date: todayNoTime));
    Finder startField = find.byKey(Key("start"));
    await tester.tap(startField);
    await tester.pump();
    await tester.tap(find.text("CANCEL"));
    await tester.pump();
    await tester.enterText(startField, DateFormat("HH:mm").format(today.subtract(Duration(minutes: 1))));
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("Start Time must be later than current time!"), findsOneWidget);

  });

  testWidgets("Validate end time must be after start time", (WidgetTester tester) async {

    await tester.pumpWidget(getApp(date: todayNoTime));
    Finder startField = find.byKey(Key("start"));
    await tester.tap(startField);
    await tester.pump();
    await tester.tap(find.text("CANCEL"));
    await tester.pump();
    await tester.enterText(startField, "14:00");
    Finder endField = find.byKey(Key("end"));
    await tester.tap(endField);
    await tester.pump();
    await tester.tap(find.text("CANCEL"));
    await tester.pump();
    await tester.enterText(endField, "13:00");
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    expect(find.text("End Time must be after Start Time"), findsOneWidget);

  });


}