import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/User.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/LoadingDialog.dart';
import 'package:orbital2020/TeacherAppDrawer.dart';
import 'package:provider/provider.dart';


class TeacherAddTask extends StatefulWidget {
  final Group group;

  TeacherAddTask({Key key, @required this.group}) : super(key: key);

  @override
  _TeacherAddTaskState createState() => _TeacherAddTaskState();
}

class _TeacherAddTaskState extends State<TeacherAddTask> {
<<<<<<< HEAD
=======

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
        drawer: TeacherAppDrawer(),
        body: AddTaskForm(group: widget.group)
    );
  }
}

class AddTaskForm extends StatefulWidget {
  final Group group;

  AddTaskForm({Key key, @required this.group}) : super(key: key);

  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
>>>>>>> master
  final _formKey = GlobalKey<FormState>();
  final _dueDateController = TextEditingController();
  final _tagController = TextEditingController();
  DatabaseController db;

  User _user;

  String _taskName;
  String _taskDescription;
  DateTime _dueDate;
  Set<String> _tags = Set<String>();

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    db = Provider.of<DatabaseController>(context, listen: false);
  }

  Future<DateTime> setDueDate(BuildContext context) async {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101)
    );
  }

  String validateDueDate(String value) {
    if (value == "") {
      return null;
    }
    String checkFormat = DateValidator("y-MM-dd", errorText: "Invalid date format! Should be y-MM-dd.").call(value);
    if (checkFormat != null){
      return checkFormat;
    } else if (DateTime.parse(value).isBefore(DateTime.now())) {
      return "Due date cannot be before today!";
    } else {
      return null;
    }
  }

  void deleteTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void addTag(String tag) {
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
    return tagChips;
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      LoadingDialog loadingDialog = LoadingDialog(context: context, text: 'Adding Task...');
      loadingDialog.show();

      _formKey.currentState.save();

      Task newTask = Task(
        name: _taskName,
        description: _taskDescription,
        createdByName: _user.name,
        createdById: _user.id,
        dueDate: _dueDate,
        tags: _tags.toList(),
      );

      db.teacherCreateTask(task: newTask, group: widget.group).then((task) {
        loadingDialog.close();

        Map<String, dynamic> arguments = {
          'task': task,
          'group': widget.group
        };
        Navigator.of(context).pushReplacementNamed('teacher_assignStudent', arguments: arguments);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Task'),
        ),
        drawer: AppDrawer(),
        body: Form(
            key: _formKey,
            child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 5),
                children: <Widget>[
                  TextFormField(
                    key: Key('name'),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                    onSaved: (value) => _taskName = value,
                    validator: RequiredValidator(errorText: "Name cannot be empty!"),
                  ),
                  AspectRatio(
                    aspectRatio: 3/2,
                    child: TextFormField(
                      key: Key('description'),
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
                            key: Key('due'),
                            decoration: const InputDecoration(
                              labelText: 'Due',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () {
                              setDueDate(context).then((value) {
                                if(value != null) {
                                  _dueDateController.text =
                                      DateFormat('y-MM-dd').format(value);
                                }
                              });
                            },
                            onSaved: (value) {
                              if (value == "") {
                                _dueDate = null;
                              } else {
                                _dueDate = DateTime.parse(value);
                              }
                            },
                            controller: _dueDateController,
                            validator: validateDueDate,
                          )
                      ),
                    ],
                  ),
                  TextFormField(
                    key: Key('tags'),
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: "Add Tag",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          if(_tagController.text.isNotEmpty) {
                            addTag(_tagController.text);
                            _tagController.text = "";
                          }
                        },
                      ),
                    ),
                    //onFieldSubmitted: (text) => addTag(text),
                    onChanged: (text) {
                      if(text.contains("\n")) {
                        if(!text.startsWith("\n")) {
                          addTag(text.trim());
                        }
                        _tagController.text = "";
                      }
                    },
                    maxLines: 2,
                    minLines: 1,
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: getTagChips(),
                  ),
                ]
            )
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: submit,
        child: Icon(Icons.check),
      ),
    );
  }
}