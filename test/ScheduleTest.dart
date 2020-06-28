import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/ScheduleDetails.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/Schedule.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:orbital2020/AppDrawer.dart';

import 'MockDatabaseController.dart';

User testUser = User(id: "I2MnlPlUYsX6ufy77OGT5gkLrBH3", name: "Vanessa Wong");

MockDatabaseController mockDB = MockDatabaseController();
Task mockTask = Task(
  id: '1234567',
  name: 'mockTask',
  description: 'mockDescription',
  createdByName: testUser.name,
  createdById: testUser.id,
  dueDate: DateTime.now(),
  tags: ['tag1', 'tag2'],
);

ScheduleDetails mockSchedule = ScheduleDetails(
    taskId: mockTask.id,
    scheduledDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    startTime: DateTime.now(),
    endTime: DateTime.now()
);
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
      child: Schedule(),
    )
);

  void runTests() {


    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();


    testWidgets("Schedule UI no schedule for the day", (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(640, 640));
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.byType(TableCalendar), findsOneWidget);
      expect(find.text("No scheduled tasks for the day!"), findsOneWidget);
    });

  testWidgets("Schedule UI with schedule for the day", (WidgetTester tester) async {
    Student student = Student(id: testUser.id, name: testUser.name);
    await mockDB.initialiseNewStudent(student);
    await mockDB.selfCreateAndAssignTask(student: student, task: mockTask);
    await mockDB.scheduleTask(student.id, mockSchedule);

    await binding.setSurfaceSize(Size(640, 640));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(find.byType(TableCalendar), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text(mockTask.name), findsOneWidget);
  });

    testWidgets("Appbar UI", (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(640, 640));
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.text("Welcome"), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets("Drawer UI", (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(640, 640));
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();
      expect(find.byType(AppDrawer), findsOneWidget);
    });

  }
