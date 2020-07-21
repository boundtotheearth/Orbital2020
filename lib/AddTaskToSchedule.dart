import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/ScheduleDetails.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';
import 'DataContainers/Task.dart';
import 'StudentAppDrawer.dart';
import 'DataContainers/User.dart';
import 'package:rxdart/rxdart.dart';

class AddTaskToSchedule extends StatefulWidget {
  AddTaskToSchedule({this.scheduledDate, this.schedule});
  final DateTime scheduledDate;
  final ScheduleDetails schedule;
  @override
  State<StatefulWidget> createState() => AddTaskToScheduleState();
}

enum Time {
  start,
  end
}

class AddTaskToScheduleState extends State<AddTaskToSchedule> {
  final _formKey = GlobalKey<FormState>();
  DatabaseController db;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TextEditingController _scheduledDateController = TextEditingController();
  bool _editable;
  bool _viewOnly = false;
  User _user;
  String _selectedTask;
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  DateTime _scheduledDate;
  Stream<Set<String>> _allUncompletedTasks;



  @override
  void initState() {
    _user = Provider.of<User>(context, listen: false);
    db = Provider.of<DatabaseController>(context, listen: false);
    _editable = widget.schedule != null;
    if (widget.scheduledDate.isBefore(today) && !_editable) {
      _scheduledDate = today;
    } else {
      _scheduledDate = widget.scheduledDate;
    }
    if (_editable) {
      _selectedTask = widget.schedule.taskId;
      _scheduledDateController.text = DateFormat("y-MM-dd").format(widget.schedule.scheduledDate);
      _startTime = TimeOfDay.fromDateTime(widget.schedule.startTime);
      _startTimeController.text = timeToString(_startTime);
      _endTime = TimeOfDay.fromDateTime(widget.schedule.endTime);
      _endTimeController.text = timeToString(_endTime);
    }
    if (_editable && widget.schedule.startTime.isBefore(DateTime.now()) ) {
      _viewOnly = true;
    }
    _scheduledDateController.text = DateFormat("y-MM-dd").format(_scheduledDate);
    _allUncompletedTasks = db.getUncompletedTasks(_user.id);
    super.initState();
  }

  Future<TimeOfDay> _setTime(BuildContext context) async {
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
    );
  }

  String timeToString(TimeOfDay time) {
    return time == null
      ? ""
      : "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
  
  TimeOfDay stringToTime(String time) {
    List<String> toArr = time.split(":");
    return TimeOfDay(hour: int.parse(toArr[0]), minute: int.parse(toArr[1]));
  }

  Future<DateTime> _setDate(BuildContext context) async {
    return showDatePicker(
        context: context,
        initialDate: _scheduledDate,
        firstDate: today,
        lastDate: DateTime(2100)
    );
  }
  
  bool isTimeAfter(String t1, String t2) {
    List<String> first = t1.split(":");
    List<String> second = t2.split(":");
    double diff = double.parse(first[0]) + double.parse(first[1]) / 60 - double.parse(second[0]) - double.parse(second[1]) / 60;
    return diff >= 0;
  }

  String validateScheduleDate(String value) {
    String checkEmpty = RequiredValidator(errorText: "Scheduled Date cannot be empty!").call(value);
    String checkFormat = DateValidator("y-MM-dd", errorText: "Invalid date format! Should be y-MM-dd.").call(value);
    if (checkEmpty != null) {
      return checkEmpty;
    } else if (checkFormat != null){
      return checkFormat;
    } else if (DateTime.parse(value).isBefore(today)) {
      return "Schedule date cannot be before today!";
    } else {
      return null;
    }
  }


  String validateEndTime(String value) {
    String checkEmpty = RequiredValidator(errorText: "End Time cannot be empty!").call(value);
    String checkFormat = DateValidator("h:mm", errorText: "Invalid time format! Should be HH:mm").call(value);
    if (checkEmpty != null) {
      return checkEmpty;
    } else if (checkFormat != null){
      return checkFormat;
    } else if (isTimeAfter(_startTimeController.text, value)) {
      return "End Time must be after Start Time";
    } else {
      return null;
    }
  }

  String validateStartTime(String value) {
    String checkEmpty = RequiredValidator(errorText: "Start Time cannot be empty!").call(value);
    String checkFormat = DateValidator("h:mm", errorText: "Invalid time format! Should be HH:mm").call(value);
    if (checkEmpty != null) {
      return checkEmpty;
    } else if (checkFormat != null){
      return checkFormat;
    }
    else if (DateTime.parse(_scheduledDateController.text) == today && !isTimeAfter(value, DateFormat.Hm().format(DateTime.now()))) {
      return "Start Time must be later than current time!";
    }
    else {
      return null;
    }
  }

  Future<bool> submit() async {
    if (_formKey.currentState.validate()) {
      print("Form is valid");
      _formKey.currentState.save();
      print("TaskId: $_selectedTask, date: $_scheduledDate, start: $_startTime, end: $_endTime");
      ScheduleDetails task = ScheduleDetails(
          id: widget.schedule?.id,
          taskId: _selectedTask,
          scheduledDate: _scheduledDate,
          startTime: _scheduledDate.add(Duration(hours: _startTime.hour, minutes: _startTime.minute)),
          endTime: _scheduledDate.add(Duration(hours: _endTime.hour, minutes: _endTime.minute)));
      if (_editable) {
        await db.updateSchedule(_user.id, task);
      } else {
        await db.scheduleTask(_user.id, task);
      }
      Navigator.pop(context);
      return Future.value(true);
    } else {
      print("Form is invalid.");
      return Future.value(false);
    }
  }

  void delete() {
    showDialog(
        context: context,
        builder: (BuildContext alertContext) => AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to delete this task from schedule?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                db.deleteScheduleById(_user.id, widget.schedule.id);
                Navigator.of(context).pop();
                Navigator.of(alertContext).pop();
              }
            ),
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(alertContext).pop(),
            )
          ],
          elevation: 24.0,
        ),
        barrierDismissible: false
    );
  }

  Widget _buildTaskDropDown() {
    if (!_viewOnly) {
      return StreamBuilder<Set<String>>(
          stream: _allUncompletedTasks,
          builder: (context, snapshot)  {
            if (!snapshot.hasData) {
              return DropdownButtonFormField(
                items: [],
                onChanged: null,
                disabledHint: Text("Loading..."),
              );
            } else {
              List<Stream<Task>> streamList = [];
              for (String taskId in snapshot.data) {
                streamList.add(db.getTaskName(taskId));
              }
              return StreamBuilder<List<Task>>(
                stream: CombineLatestStream.list(streamList),
                builder: (context, snapshot) {
                  print(snapshot.data);
                  return DropdownButtonFormField(
                    items: snapshot.data?.map((task) => DropdownMenuItem(
                      child: Text(task.name),
                      value: task.id,
                    )
                    )?.toList(),
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
                },
              );
            }
          }
      );
    } else {
      return StreamBuilder<Task>(
        stream: db.getTaskName(widget.schedule.taskId),
        builder: (context, snapshot) {
          return DropdownButtonFormField(
            items: [],
            onChanged: null,
            disabledHint: snapshot.hasData ? Text(snapshot.data.name) : Text("Loading..."),
          );
        },
      );
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      onWillPop: () async {
        return _editable ? submit().then((value) => value) : true;
      },
      child: ListView(
        children: <Widget>[
          _buildTaskDropDown(),
          TextFormField(
            key: Key("date"),
            decoration: InputDecoration(
                labelText: "Scheduled Date",
                suffixIcon: Icon(Icons.calendar_today)
            ),
            enabled: !_viewOnly,
            onTap: () {
              _setDate(context).then((value) {
                if (value != null) {
                  _scheduledDateController.text =
                      DateFormat("y-MM-dd").format(value);
                }
              });
            },
            onSaved: (value) => _scheduledDate = DateTime.parse(value),
            controller: _scheduledDateController,
            validator: validateScheduleDate
          ),
          TextFormField(
            key: Key("start"),
            decoration: InputDecoration(
              labelText: "Start Time",
              suffixIcon: Icon(Icons.timer)
            ),
            enabled: !_viewOnly,
            onTap: () {
              _setTime(context).then((value) {
                if (value != null) {
                  _startTimeController.text = timeToString(value);
                }
              });
            },
            onSaved: (value) => _startTime = stringToTime(value),
            controller: _startTimeController,
            validator: validateStartTime
          ),
          TextFormField(
            key: Key("end"),
            decoration: InputDecoration(
                labelText: "End Time",
                suffixIcon: Icon(Icons.timer)
            ),
            enabled: !_viewOnly,
            onTap: () {
              _setTime(context).then((value) {
                if (value != null) {
                  _endTimeController.text = timeToString(value);
                }
              });
            },
            onSaved: (value) => _endTime = stringToTime(value),
            controller: _endTimeController,
            validator: validateEndTime
          ),
          _editable ? RaisedButton(onPressed: delete, child: const Text("Delete from Schedule"))
            : RaisedButton(onPressed: submit, child: const Text("Add to Schedule"))
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
      drawer: StudentAppDrawer(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 17.0),
        child: _buildForm()
      )
    );
  }



}