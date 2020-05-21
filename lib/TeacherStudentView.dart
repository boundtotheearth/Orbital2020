import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

import 'AppDrawer.dart';


class TeacherStudentView extends StatefulWidget {
  final Student student;

  TeacherStudentView({Key key, @required this.student}) : super(key: key);

  @override
  _TeacherStudentViewState createState() => _TeacherStudentViewState();
}

class _TeacherStudentViewState extends State<TeacherStudentView> {
  final DatabaseController db = DatabaseController();

  User _user;
  Stream<List<TaskWithStatus>> _tasks;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _tasks = db.getStudentTaskSnapshots(studentId: widget.student.id, teacherId: _user.id);
  }

  Widget _buildTaskList(List<TaskWithStatus> tasks) {
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          TaskWithStatus task = tasks[index];
          return ListTile(
            title: Text(task.name),
            trailing: task.createdById == _user.id ? Wrap(
              children: <Widget>[
                Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    db.updateTaskCompletion(task.id, widget.student.id, value);
                  },
                ),
                Checkbox(
                  value: task.verified,
                  onChanged: (value) {
                    db.updateTaskVerification(task.id, widget.student.id, value);
                  },
                ),
              ],
            ) : Text('Task not created by you!')
          );
        }
    );
  }

  Future<Null> _refresh() async {
    await Future.microtask(() => setState(() {
      _tasks = db.getStudentTaskSnapshots(studentId: widget.student.id);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
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
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text("Task"),
                  ),
                  Text("Completed"),
                  Text("Verified")
                ],
              ),
              Expanded(
                child: Scrollbar(
                  child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: StreamBuilder(
                        stream: _tasks,
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            if(snapshot.data.length > 0) {
                              return _buildTaskList(snapshot.data);
                            } else {
                              return Text('No tasks assigned!');
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      )
                  ),
                ),
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Assign Task',
        onPressed: () {
          Navigator.of(context).pushNamed('teacher_assignTask');
        },
      ),
    );
  }
}