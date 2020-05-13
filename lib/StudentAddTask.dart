import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Task name'),
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

  DateTime dueDate;
  List<String> mockTags = ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'];

  @override
  void initState() {
    super.initState();
    dueDate = DateTime.now();
  }

  Future<Null> setDueDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        dueDate = picked;
      });
  }

  void deleteTag(String tag) {
    setState(() {
      mockTags.remove(tag);
    });
  }

  void addtag(String tag) {
    setState(() {
      mockTags.add(tag);
    });
  }

  List<Widget> getTagChips() {
    List<Widget> tagChips = <Widget>[];
    for(String tag in mockTags) {
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

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
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
                      _dueDateController.text = DateFormat('dd/MM/y').format(dueDate);
                    },
                    controller: _dueDateController,
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
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Scaffold
                          .of(context)
                          .showSnackBar(SnackBar(content: Text('Processing Data')));
                    }
                  },
                  child: const Text('Save'),
                )
              ],
            )
          ]
        )
    );
  }
}