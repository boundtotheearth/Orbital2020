import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/TaskStatusTile.dart';
import 'package:provider/provider.dart';

import 'AppDrawer.dart';
import 'DataContainers/Task.dart';
import 'DataContainers/TaskStatus.dart';


class TeacherStudentView extends StatefulWidget {
  final Student student;
  final Group group;

  TeacherStudentView({Key key, @required this.student, @required this.group}) : super(key: key);

  @override
  _TeacherStudentViewState createState() => _TeacherStudentViewState();
}

class _TeacherStudentViewState extends State<TeacherStudentView> {
  final DatabaseController db = DatabaseController();

  User _user;
  Stream<Set<TaskStatus>> _tasks;
  String _searchText;
  bool _searchBarActive;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _tasks = db.getStudentTaskDetailsSnapshots(studentId: widget.student.id);
    _searchText = '';
    _searchBarActive = false;
  }

  bool filtered(Task task) {
    return task.name.toLowerCase().startsWith(_searchText);
  }

  Widget _buildTaskList(List<TaskStatus> tasks) {

    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          TaskStatus task = tasks[index];
          return StreamBuilder<Task>(
            stream: db.getTask(task.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && filtered(snapshot.data)) {
                return TaskStatusTile(
                    task: snapshot.data.addStatus(task.completed, task.verified),
                    isStudent: _user.accountType == 'student',
                    updateComplete: (value) {
                      db.updateTaskCompletion(task.id, widget.student.id, value);
                    },
                    updateVerify: (value) {
                      db.updateTaskVerification(task.id, widget.student.id, value);
                    },
                    onFinish: () {},
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
  }

  List<PopupMenuItem> _actionMenuBuilder(BuildContext context) {
    return [
      PopupMenuItem(
        value: 'remove_student',
        child: Text('Remove Student'),
      ),
    ];
  }

  void _onActionMenuSelected(dynamic value) {
    switch(value) {
      case 'remove_student':
        _onRemoveStudent();
        break;
      default:
        print(value.toString() + " Not Implemented");
    }
  }

  Future<void> _onRemoveStudent() {
    return Future(null);
  }

  void _activateSearchBar() {
    setState(() {
      _searchBarActive = true;
    });
  }

  Widget buildAppBar() {
    if(_searchBarActive) {
      return AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search',
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value.toLowerCase();
            });
          },
          autofocus: true,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.cancel),
            tooltip: 'Cancel',
            onPressed: _deactivateSearchBar,
          )
        ],
      );
    } else {
      return AppBar(
        title: Text(widget.student.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _activateSearchBar,
          ),
          PopupMenuButton(
            itemBuilder: _actionMenuBuilder,
            onSelected: _onActionMenuSelected,
          ),
        ],
      );
    }
  }

  void _deactivateSearchBar() {
    setState(() {
      _searchBarActive = false;
    });
  }

  Future<Null> _refresh() async {
    await Future.microtask(() => setState(() {
      _tasks = db.getStudentTaskDetailsSnapshots(studentId: widget.student.id);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: AppDrawer(),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Scrollbar(
                  child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: StreamBuilder(
                        stream: _tasks,
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            if(snapshot.data.length > 0) {
                              return _buildTaskList(snapshot.data.toList());
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
          Map<String, dynamic> arguments = {
            'student': widget.student,
            'group': widget.group
          };
          Navigator.of(context).pushNamed('teacher_assignTask', arguments: arguments);
        },
      ),
    );
  }
}