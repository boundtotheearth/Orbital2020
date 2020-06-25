import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning tasks to a student
class TeacherAssignTask extends StatefulWidget {
  final DatabaseController databaseController;
  final Student student;
  final Group group;

  TeacherAssignTask({Key key, this.databaseController, @required this.student, @required this.group}) : super(key: key);


  @override
  _TeacherAssignTaskState createState() => _TeacherAssignTaskState();
}

class _TeacherAssignTaskState extends State<TeacherAssignTask> {
  DatabaseController db;

  User _user;

//  Stream<Set<Task>> _allTasks;
//  Stream<Set<TaskStatus>> _alreadyAssigned;
//  Stream<Set<String>> _allTasks;
//  Stream<Set<String>> _alreadyAssigned;
  Set<Task> _tasks;
  String _searchText;


  @override
  void initState() {
    super.initState();
    db = widget.databaseController ?? DatabaseController();
    _user = Provider.of<User>(context, listen: false);
//    _allTasks = db.getGroupTaskSnapshots(teacherId: _user.id, groupId: widget.group.id);
//    _alreadyAssigned = db.getStudentTaskDetailsSnapshots(studentId: widget.student.id);
//    _allTasks = db.getGroupTaskSnapshots(teacherId: _user.id, groupId: widget.group.id);
//    _alreadyAssigned = db.getStudentTaskDetailsSnapshots(studentId: widget.student.id).map((tasks) {
//      Set<String> set = Set();
//      for(TaskStatus task in tasks) {
//        set.add(task.id);
//      }
//      return set;
//    });
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

  bool filtered(Task task) {
    return task.name.startsWith(_searchText) && !_tasks.contains(task);
  }

  Widget buildSuggestions() {
    return StreamBuilder(
      stream: db.getUnassignedTasks(_user.id, widget.group.id, widget.student.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  String taskId = snapshot.data.elementAt(index);
                  return StreamBuilder<Task>(
                    stream: db.getTask(taskId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && filtered(snapshot.data)) {
                        return ListTile(
                          title: Text(snapshot.data.name),
                          onTap: () {
                            addTask(snapshot.data);
                          },
                        );
                      } else if (snapshot.hasData) {
                        return Container(width: 0.0, height: 0.0,);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }
                  );
                }
            );
          } else {
            return CircularProgressIndicator();
          }
      });
  }

  Future<void> submitAssignment() {
    return db.teacherAssignTasksToStudent(_tasks, widget.student);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: BackButtonIcon(),
          onPressed: Navigator.of(context).maybePop,
          tooltip: 'Back',
        ),
        title: const Text('Assign Task To Student'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Assign Tasks',
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