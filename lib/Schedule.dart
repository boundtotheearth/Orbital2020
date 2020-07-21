import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/ScheduleDetails.dart';
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
  DatabaseController db;
  Map<DateTime, List> _scheduledTasks;
  List _selectedTasks;
  final CalendarController _calendarController = CalendarController();
  final formatTime = DateFormat.Hm();
  DateTime _selectedDate;
  User _user;

  @override
  void initState() {
    super.initState();
    db = Provider.of<DatabaseController>(context, listen: false);
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
        if (snapshot.hasData) {
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
              rowHeight: 42,
              headerStyle: HeaderStyle(
                headerPadding: EdgeInsets.only(top: 5),
                formatButtonVisible: false,
                centerHeaderTitle: true,
              ),
              builders: CalendarBuilders(
                markersBuilder: (context, date, events, holidays) {
                  final children = <Widget>[];
                  if (events.isNotEmpty) {
                    children.add(Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, events),
                    ));
                  }
                  return children;
                }
              ),
            ),
            Expanded(
                child: _buildTask(_selectedTasks)
            )
        ]

        );
      }
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
          ? Colors.orange[500] : _calendarController.isToday(date)
            ? Colors.red[500] : Colors.orange[200]
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text("${events.length}",
          style: TextStyle(color: Colors.white, fontSize: 12.0)
        )
      ),
    );
  }

  Widget _buildTask(List tasks) {
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    if (tasks.isEmpty) {
      return Text("No scheduled tasks for the day!");
    } else {
      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          ScheduleDetails task = tasks[index];
          return ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("From ${formatTime.format(task
                      .startTime)} to ${formatTime.format(task
                      .endTime)}"),
                ],
              ),
              title: Text(task.taskName), //task.name),
              onTap: () {
                Map<String, dynamic> arguments = {
                  'date': _selectedDate,
                  'schedule': task
                };
                Navigator.of(context).pushNamed("addSchedule", arguments: arguments);
              }
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
        onPressed: () {
          Map<String, dynamic> arguments = {
            'date': _selectedDate,
          };
          Navigator.of(context).pushNamed(
              "addSchedule", arguments: arguments);
        },
      ),
    );
  }

}