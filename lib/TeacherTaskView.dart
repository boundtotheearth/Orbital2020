import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/StudentWithStatus.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskStatus.dart';
import 'package:orbital2020/DatabaseController.dart';

import 'AppDrawer.dart';


class TeacherTaskView extends StatefulWidget {
  final Task task;
  final Group group;

  TeacherTaskView({Key key, @required this.task, @required this.group}) : super(key: key);

  @override
  _TeacherTaskViewState createState() => _TeacherTaskViewState();
}

class _TeacherTaskViewState extends State<TeacherTaskView> {
  final DatabaseController db = DatabaseController();

//  Stream<List<StudentWithStatus>> _students;
  Stream<List<String>> _studentIds;
  String _searchText;
  bool _searchBarActive;

  @override
  void initState() {
    super.initState();
//    _students = db.getTaskCompletionSnapshots(widget.task.id);
    _studentIds = db.getStudentsWithTask(widget.task.id);
    _searchText = '';
    _searchBarActive = false;
  }

//  Widget _buildStudentList(List<StudentWithStatus> students) {
//    List<StudentWithStatus> filteredStudents = students.where((student) =>
//        student.name.toLowerCase().startsWith(_searchText)).toList();
//
//    return ListView.builder(
//        itemCount: filteredStudents.length,
//        itemBuilder: (context, index) {
//          StudentWithStatus student = filteredStudents[index];
//          return ListTile(
//            title: Text(student.name),
//            trailing: Wrap(
//              children: <Widget>[
//                Checkbox(
//                  value: student.completed,
//                  onChanged: (value) {
//                    db.updateTaskCompletion(widget.task.id, student.id, value);
//                  },
//                ),
//                Checkbox(
//                  value: student.verified,
//                  onChanged: (value) {
//                    db.updateTaskVerification(widget.task.id, student.id, value);
//                  },
//                ),
//              ],
//            ),
//          );
//        }
//    );
//  }

  bool filtered(String studentName) {
    return studentName.toLowerCase().startsWith(_searchText);
  }




  Widget _buildStudentList(List<String> studentIds) {

    return ListView.builder(
        itemCount: studentIds.length,
        itemBuilder: (context, index) {
          String studentId = studentIds[index];
          //get task status stream for that student
          return StreamBuilder<TaskStatus>(
            stream: db.getStudentNameTaskStatus(studentId, widget.task.id),//db.getStudentTaskDetailsSnapshots(studentId: studentId),
            builder: (context, snapshot) {
              if (snapshot.hasData && filtered(snapshot.data.name)) {
                return ListTile(
                  title: Text(snapshot.data.name),
                  trailing: Wrap(
                    children: <Widget>[
                      Checkbox(
                        value: snapshot.data.completed,
                        onChanged: (value) {
                          db.updateTaskCompletion(
                              widget.task.id, studentId,
                              value);
                        },
                      ),
                      Checkbox(
                        value: snapshot.data.verified,
                        onChanged: (value) {
                          db.updateTaskVerification(
                              widget.task.id, studentId,
                              value);
                        },
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                return Container(width: 0.0, height: 0.0);
              } else {
                return CircularProgressIndicator();
              }
            });

        });
  }

  Future<Null> _refresh() async {
    await Future.microtask(() => setState(() {
//      _students = db.getTaskCompletionSnapshots(widget.task.id);
      _studentIds = db.getStudentsWithTask(widget.task.id);
    }));
  }

  List<PopupMenuItem> _actionMenuBuilder(BuildContext context) {
    return [
      PopupMenuItem(
        value: 'all_submitted',
        child: Text('All Submitted'),
      ),
      PopupMenuItem(
        value: 'clear_all',
        child: Text('Clear All'),
      ),
      PopupMenuItem(
        value: 'archive',
        child: Text('Archive'),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Text('Delete', style: TextStyle(color: Colors.red),),
      )
    ];
  }

  void _onActionMenuSelected(dynamic value) {
    switch(value) {
      case 'all_submitted':
        _onAllSubmitted();
        break;
      case 'clear_all':
        _onClearAll();
        break;
      case 'archive':
        _onArchive();
        break;
      case 'delete':
        _onDelete();
        break;
      default:
        print(value.toString() + " Not Implemented");
    }
  }

  Future<void> _onAllSubmitted() {
    return Future(null);
  }

  Future<void> _onArchive() {
    return Future(null);
  }

  Future<void> _onClearAll() {
    return Future(null);
  }

  Future<void> _onDelete() {
    return Future(null);
  }

  void _activateSearchBar() {
    setState(() {
      _searchBarActive = true;
    });
  }

  void _deactivateSearchBar() {
    setState(() {
      _searchBarActive = false;
    });
  }

  Widget buildAppBar() {
    if (_searchBarActive) {
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
        title: Text(widget.task.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
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

  List<Widget> getTagChips() {
    List<Widget> tagChips = <Widget>[];
    for(String tag in widget.task.tags) {
      tagChips.add(Chip(
        label: Text(tag),
      ));
    }
    return tagChips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: AppDrawer(),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 3/2,
                child: Container(),
              ),
              Text(widget.task.description ?? "No Description"),
              Text("Due: " + DateFormat('dd/MM/y').format(widget.task.dueDate)),
              Text('Tags:'),
              Wrap(
                spacing: 8.0,
                children: getTagChips(),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text("Student"),
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
                        stream: _studentIds,//_students,
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            if(snapshot.data.length > 0) {
                              return _buildStudentList(snapshot.data);
                            } else {
                              return Text('No students assigned!');
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
        tooltip: 'Add Student',
        onPressed: () {
          Map<String, dynamic> arguments = {
            'task': widget.task,
            'group': widget.group
          };
          Navigator.of(context).pushNamed('teacher_assignStudent', arguments: arguments);
        },
      ),
    );
  }
}