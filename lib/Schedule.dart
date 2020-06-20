

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/ScheduleDetails.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'AppDrawer.dart';
import 'DataContainers/Task.dart';
import 'DataContainers/User.dart';

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final DatabaseController db = DatabaseController();
  Map<DateTime, List> _scheduledTasks;
  List _selectedTasks;
  final CalendarController _calendarController = CalendarController();
  final formatTime = DateFormat.Hm();
  DateTime _selectedDate;
  User _user;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _scheduledTasks = {};
    _selectedTasks = [];
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date, List tasks) {
    this.setState(() {
      _selectedDate = date.toLocal().subtract(Duration(hours: 20));
    });
  }

  Map<DateTime, List> _mapToScheduledDate(List tasks) {
    Map<DateTime, List> map = {};
    tasks.forEach((task) {
      DateTime date = task.scheduledDate;
      if (map[date] == null) {
        map[date] = [];
      }
      map[date].add(task);
    });
    return map;
  }


  Widget _buildCalendar() {
    return StreamBuilder<List>(
      stream: db.getScheduleDetailsSnapshots(_user.id),
      builder: (context, snapshot) {
        print("here");
        if (snapshot.hasData) {
          print("there");
          List allTasks = snapshot.data;
          print(allTasks);
          _scheduledTasks = _mapToScheduledDate(allTasks);
          print(_selectedDate);
          _selectedTasks = _scheduledTasks[_selectedDate] ?? [];
          print(_selectedTasks);

        }
        return Column(
          children: <Widget>[
            TableCalendar(
              calendarController: _calendarController,
              events: _scheduledTasks,
              onDaySelected: _onDateSelected,
            ),
            Expanded(
                child: _buildTask(_selectedTasks)
            )
        ]

        );
      }
    );
  }

  Widget _buildTask(List tasks) {
    print("hello");
    if (tasks.isEmpty) {
      return Text("No scheduled tasks for the day!");
    } else {
      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          ScheduleDetails task = tasks[index];
          return StreamBuilder<Task>(
            stream: db.getTask(task.taskId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print("rebuild");
                return ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("From ${formatTime.format(task
                            .startTime)} to ${formatTime.format(task
                            .endTime)}"),
                      ],
                    ),
                    title: Text(snapshot.data.name), //task.name),
                    onTap: () {}

                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        //padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildCalendar()
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed("addSchedule", arguments: _selectedDate),
      ),
    );
  }

}