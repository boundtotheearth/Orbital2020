import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/ScheduleDetails.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

import 'AppDrawer.dart';
import 'DataContainers/User.dart';

class AddTaskToSchedule extends StatefulWidget {
  AddTaskToSchedule({this.scheduledDate});
  final DateTime scheduledDate;
  @override
  State<StatefulWidget> createState() => AddTaskToScheduleState();
}

enum Time {
  start,
  end
}

class AddTaskToScheduleState extends State<AddTaskToSchedule> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseController db = DatabaseController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TextEditingController _scheduledDateController;
  User _user;
  String _selectedTask;
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  DateTime _scheduledDate;



  @override
  void initState() {
    _user = Provider.of<User>(context, listen: false);
    _scheduledDate = widget.scheduledDate.isBefore(today) ? today : widget.scheduledDate;
    _scheduledDateController = TextEditingController(text: DateFormat("dd/MM/y").format(_scheduledDate));
    super.initState();
  }

  Future<TimeOfDay> _setTime(BuildContext context, Time timeType) async {
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()).then((value) {
          timeType == Time.start ? _startTime = value : _endTime = value;
          return value;
    });
  }

  Future<DateTime> _setDate(BuildContext context) async {
    return showDatePicker(
        context: context,
        initialDate: _scheduledDate,
        firstDate: today,
        lastDate: DateTime(2100)
    ).then((value) {
      _scheduledDate = value;
      return _scheduledDate;
    });
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      print("Form is valid");
      _formKey.currentState.save();
      print("TaskId: $_selectedTask, date: $_scheduledDate, start: $_startTime, end: $_endTime");
      ScheduleDetails task = ScheduleDetails(
          taskId: _selectedTask,
          scheduledDate: _scheduledDate,
          startTime: _scheduledDate.add(Duration(hours: _startTime.hour, minutes: _startTime.minute)),
          endTime: _scheduledDate.add(Duration(hours: _endTime.hour, minutes: _endTime.minute)));
      db.scheduleTask(_user.id, task);
      Navigator.pop(context);
    } else {
      print("Form is invalid.");
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          StreamBuilder(
            stream: db.getStudentTaskDetailsSnapshots(studentId: _user.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                List<DropdownMenuItem> tasks = [];
                for (TaskWithStatus t in snapshot.data) {
                  tasks.add(
                    DropdownMenuItem(
                      child: Text(t.name),
                      //temp solution
                      value: "${t.id}",

                    )
                  );
                }
                return DropdownButtonFormField(
                  items: tasks,
                  onChanged: (selected) {
                    print(selected);
                    setState(() {
                      _selectedTask = selected;
                    });
                  },
                  value: _selectedTask,
                  hint: Text("Select Task"),
                  validator: (input) {
                    if (input == null) {
                      return "Task cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  isExpanded: true,
                );
              }
            }
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: "Scheduled Date",
                suffixIcon: Icon(Icons.calendar_today)
            ),
            onTap: () {
              _setDate(context).then((value) {
                _scheduledDateController.text = DateFormat("dd/MM/y").format(value);
              });
            },
            controller: _scheduledDateController,
            validator: MultiValidator([
              RequiredValidator(errorText: "Scheduled Date cannot be empty!"),
              DateValidator("dd/MM/y", errorText: "Invalid date format! Should be dd/MM/y.")
            ]),
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Start Time",
              suffixIcon: Icon(Icons.timer)
            ),
            onTap: () {
              _setTime(context, Time.start).then((value) {
                _startTimeController.text = DateFormat("HH:mm")
                  .format(_scheduledDate.add(Duration(hours: value.hour, minutes: value.minute)));
              });
            },
            controller: _startTimeController,
            validator: MultiValidator([
              RequiredValidator(errorText: "Start Time cannot be empty!"),
              DateValidator("h:mm", errorText: "Invalid time format! Should be HH:mm")
            ]),
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: "End Time",
                suffixIcon: Icon(Icons.timer)
            ),
            onTap: () {
              _setTime(context, Time.end).then((value) {
                _endTimeController.text = DateFormat("HH:mm")
                    .format(_scheduledDate.add(Duration(hours: value.hour, minutes: value.minute)));
              });
            },
            controller: _endTimeController,
            validator: MultiValidator([
              RequiredValidator(errorText: "End Time cannot be empty!"),
              DateValidator("h:mm", errorText: "Invalid time format! Should be HH:mm"),
            ]),
          ),
          RaisedButton(
            onPressed: submit,
            child: const Text("Add to Schedule")
          )
        ],
      )
    );
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 17.0),
        child: _buildForm()
      )
    );
  }



}