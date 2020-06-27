import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:form_field_validator/form_field_validator.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:provider/provider.dart';

import 'DataContainers/User.dart';


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
      Scaffold
          .of(context)
          .showSnackBar(SnackBar(content: Text('Processing Data')));

      _formKey.currentState.save();

      Task newTask = Task(
        name: _taskName,
        description: _taskDescription,
        createdByName: _user.name,
        createdById: _user.id,
        dueDate: _dueDate,
        tags: _tags.toList(),
      );

      Student me = Student(id: _user.id, name: _user.name);

      db.selfCreateAndAssignTask(task: newTask, student: me).then((value) {
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Success')));
        Navigator.of(context).pushReplacementNamed('student_main');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            TextFormField(
              key: Key('due'),
              decoration: const InputDecoration(
                labelText: 'Due',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                setDueDate(context).then((value) {
                  if(value != null) {
                    _dueDateController.text =
                        DateFormat('dd/MM/y').format(value);
                  }
                });
              },
              controller: _dueDateController,
              validator: DateValidator('dd/MM/y', errorText: 'Invalid date format!'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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