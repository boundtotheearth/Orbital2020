import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/TaskStatusTile.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'AppDrawer.dart';
import 'DataContainers/Task.dart';
import 'DataContainers/TaskStatus.dart';
import 'Sort.dart';


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
  Sort _sortBy;
  List<DropdownMenuItem> _options = [
    DropdownMenuItem(child: Text("Name"), value: Sort.name,),
    DropdownMenuItem(child: Text("Due Date"), value: Sort.dueDate,),
    DropdownMenuItem(child: Text("Created By"), value: Sort.createdBy,),
    DropdownMenuItem(child: Text("Completion Status"), value: Sort.status,),
  ];

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _tasks = db.getStudentTaskDetailsSnapshots(studentId: widget.student.id);
    _searchText = '';
    _searchBarActive = false;
    _sortBy = Sort.status;
  }

  bool filtered(Task task) {
    return task.name.toLowerCase().startsWith(_searchText);
  }

  List<TaskWithStatus> sortAndFilter(List<TaskWithStatus> originalTasks) {
    List<TaskWithStatus> filteredTask = originalTasks.where((task) => filtered(task)).toList();
    switch (_sortBy) {
      case Sort.name:
        filteredTask.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return filteredTask;
      case Sort.dueDate:
        filteredTask.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) {
            return 0;
          } else if (a.dueDate == null) {
            return 1;
          } else if (b.dueDate == null) {
            return -1;
          } else {
            return a.dueDate.compareTo(b.dueDate);
          }
        });
        return filteredTask;
      case Sort.createdBy:
        filteredTask.sort((a, b) => a.createdByName.toLowerCase().compareTo(b.createdByName.toLowerCase()));
        return filteredTask;
      case Sort.status:
        filteredTask.sort((a, b) => a.getStatusTeacher(_user.id).compareTo(b.getStatusTeacher(_user.id)));
        return filteredTask;
      default:
        filteredTask.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return filteredTask;
    }
  }

  Widget _buildTaskList(List<TaskStatus> tasks) {
    List<Stream<TaskWithStatus>> streamList = [];
    tasks.forEach((status) {
      streamList.add(db.getTaskWithStatus(status));
    });
    return StreamBuilder<List<TaskWithStatus>>(
      stream: CombineLatestStream.list(streamList),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<TaskWithStatus> filteredTasks = sortAndFilter(snapshot.data);
          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              TaskWithStatus task = filteredTasks[index];
              return TaskStatusTile(
                task: task,
                isStudent: false,//_user.accountType == "student",
                updateComplete: (value) {
                  db.updateTaskCompletion(task.id, widget.student.id, value);
                },
                updateVerify: (value) {
                  db.updateTaskVerification(task.id, widget.student.id, value);
                },
                onFinish: () {},
              );
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
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
    return db.teacherRemoveStudentFromGroup(teacherId: _user.id, group: widget.group, student: widget.student)
        .then((value) {

      Navigator.of(context).pop();
    });
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
      _searchText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: AppDrawer(),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField(
                      items: _options,
                      decoration: InputDecoration(
                          labelText: "Sort By: "
                      ),
                      onChanged: (value) => setState(() => _sortBy = value),
                      value: _sortBy,
                    ),
                  )
              ),
              Expanded(
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
                ),
              )
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