import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning a task to a student
class TeacherAssignTask extends StatefulWidget {
  final Student student;

  TeacherAssignTask({Key key, @required this.student}) : super(key: key);


  @override
  _TeacherAssignTaskState createState() => _TeacherAssignTaskState();
}

class _TeacherAssignTaskState extends State<TeacherAssignTask> {
  final DatabaseController db = DatabaseController();

  User _user;

  Stream<List<Task>> _allTasks;
  Set<Task> _tasks;
  String _searchText;


  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _allTasks = db.getTeacherTasksSnapshots(teacherId: _user.id);
    _tasks = Set();
    _searchText = "";
  }

  List<Widget> buildChips() {
    List<Widget> taskChips = <Widget>[];
    for(Task task in _tasks) {
      taskChips.add(Chip(
        label: Text(task.name),
        onDeleted: () {
          deleteTask(task);
        },
      ));
    }
    return taskChips;
  }

  void deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  void addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  Widget buildSuggestions() {
    return StreamBuilder(
      stream: _allTasks,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          List<Task> allTasks = snapshot.data;
          List<Task> suggestions = allTasks.where((element) =>
              element.name.startsWith(_searchText)).toList();
          return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                Task task = suggestions[index];
                return ListTile(
                  title: Text(task.name),
                  onTap: () {
                    addTask(task);
                  },
                );
              }
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> submitAssignment() {
    return db.teacherAssignTasksToStudent(_tasks, widget.student);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Add Students/Groups',
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
            Wrap(
              children: buildChips(),
            ),
            Expanded(
              child: buildSuggestions(),
            ),
            RaisedButton(
              child: const Text('Add New Task'),
              onPressed: () {

              },
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: 'Assign Task',
        onPressed: () {
          submitAssignment()
              .then((value) => Navigator.pop(context));
        },
      ),
    );
  }
}