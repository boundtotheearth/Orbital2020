import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/Task.dart';

import 'AppDrawer.dart';


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
  final _dueDateController = TextEditingController();
  final db = DatabaseController();

  String _taskName;
  String _taskDescription;
  DateTime _dueDate;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now();
  }

  Future<Null> setDueDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        _dueDate = picked;
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
        createdBy: 'Me',
        dueDate: _dueDate,
        tags: _tags,
      );

      db.createAndAssign(newTask, 'Rsd56J6FqHEFFg12Uf3M').then((value) {
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Success')));
        Navigator.pop(context);
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
                      setDueDate(context);
                      _dueDateController.text = DateFormat('dd/MM/y').format(_dueDate);
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