import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:form_field_validator/form_field_validator.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:provider/provider.dart';


class StudentAddTask extends StatefulWidget {
  StudentAddTask({Key key}) : super(key: key);


  @override
  _StudentAddTaskState createState() => _StudentAddTaskState();
}

class _StudentAddTaskState extends State<StudentAddTask> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      drawer: AppDrawer(),
      body: AddTaskForm()
    );
  }
}

class AddTaskForm extends StatefulWidget {
  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _dueDateController = TextEditingController(text: "None");
  final db = DatabaseController();


  FirebaseUser _user;
  String _taskName;
  String _taskDescription;
  DateTime _dueDate;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _user = Provider.of<FirebaseUser>(context, listen: false);
  }

  Future<DateTime> setDueDate(BuildContext context) async {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101)
    ).then((date) {
      setState(() {
        _dueDate = date;
      });
      return date;
    });
  }

  void deleteTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void addtag(String tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  List<Widget> getTagChips() {
    List<Widget> tagChips = <Widget>[];
    for(String tag in _tags) {
      tagChips.add(Chip(
        label: Text(tag),
        onDeleted: () {
          deleteTag(tag);
        },
      ));
    }
    tagChips.add(ActionChip(
      avatar: Icon(Icons.add),
      onPressed: () {
        addtag('new tag');
      },
      label: Text('Add Tag'),
    ));
    return tagChips;
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      Scaffold
          .of(context)
          .showSnackBar(SnackBar(content: Text('Processing Data')));

      _formKey.currentState.save();

      Task newTask = Task(
        name: _taskName,
        description: _taskDescription,
        createdByName: _user.displayName,
        dueDate: _dueDate,
        tags: _tags,
      );

      Student me = Student(id: _user.uid, name: 'Me');

      db.selfCreateAndAssignTask(task: newTask, student: me).then((value) {
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Success')));
        Navigator.pushReplacementNamed(context, 'main');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              onSaved: (value) => _taskName = value,
              validator: RequiredValidator(errorText: "Name cannot be empty!"),
            ),
            AspectRatio(
              aspectRatio: 3/2,
              child: TextFormField(
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Description',
                ),
                textAlignVertical: TextAlignVertical.top,
                expands: true,
                minLines: null,
                maxLines: null,
                onSaved: (value) => _taskDescription = value,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Due',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () {
                      setDueDate(context).then((value) {
                        if(value != null) {
                          _dueDateController.text =
                              DateFormat('dd/MM/y').format(value);
                        } else {
                          print("here");
                          _dueDateController.text = "None";
                        }
                      });
                    },
                    controller: _dueDateController,
                    validator: DateValidator('dd/MM/y', errorText: 'Invalid date format!'),
                  )
                ),
              ],
            ),
            Text('Tags:'),
            Wrap(
              spacing: 8.0,
              children: getTagChips(),
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Scaffold
                          .of(context)
                          .showSnackBar(SnackBar(content: Text('Processing Data')));
                    }
                  },
                  child: const Text('Submit & Save'),
                ),
                Spacer(),
                RaisedButton(
                  onPressed: submit,
                  child: const Text('Save'),
                )
              ],
            )
          ]
        )
    );
  }
}