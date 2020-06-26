import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/Schedule.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:orbital2020/AppDrawer.dart';


void main() {

  User userWithoutSchedule = User(id: "P6IYsnpoAZZTdmy2aLBHYHrMf6E2", name: "FarrellStu");
  User userWithSchedule;
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();

  Widget makeTestable({Widget page, User user}) {
    return MaterialApp (
        home: Provider<User>(
          create: (_) => user,
          child: page,
        )
    );
  }

  testWidgets("Schedule UI no schedule for the day", (WidgetTester tester) async {
    await binding.setSurfaceSize(Size(640, 640));
    await tester.pumpWidget(makeTestable(page: Schedule(), user: userWithoutSchedule));
    expect(find.byType(TableCalendar), findsOneWidget);
    expect(find.text("No scheduled tasks for the day!"), findsOneWidget);
  });

  testWidgets("Schedule UI with schedule for the day", (WidgetTester tester) async {
    await binding.setSurfaceSize(Size(640, 640));
    await tester.pumpWidget(makeTestable(page: Schedule(), user: userWithSchedule));
    expect(find.byType(TableCalendar), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets("Appbar UI", (WidgetTester tester) async {
    await binding.setSurfaceSize(Size(640, 640));
    await tester.pumpWidget(makeTestable(page: Schedule(), user: userWithoutSchedule));
    expect(find.text("Welcome"), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets("Drawer UI", (WidgetTester tester) async {
    await binding.setSurfaceSize(Size(640, 640));
    await tester.pumpWidget(makeTestable(page: Schedule(), user: userWithoutSchedule));
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(find.byType(AppDrawer), findsOneWidget);
  });

}