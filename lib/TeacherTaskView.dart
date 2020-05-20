import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/StudentWithStatus.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DatabaseController.dart';

import 'AppDrawer.dart';


class TeacherTaskView extends StatefulWidget {
  final String userId;
  final Task task;

  TeacherTaskView({Key key, this.userId, this.task}) : super(key: key);

  @override
  _TeacherTaskViewState createState() => _TeacherTaskViewState();
}

class _TeacherTaskViewState extends State<TeacherTaskView> {
  final DatabaseController db = DatabaseController();

  Stream<List<StudentWithStatus>> _students;

  @override
  void initState() {
    super.initState();
    _students = db.getTaskCompletionSnapshots(widget.task.id);
  }

  Widget _buildStudentList(List<StudentWithStatus> students) {
    return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          StudentWithStatus student = students[index];
          return ListTile(
            title: Text(student.name),
            trailing: Wrap(
              children: <Widget>[
                Checkbox(
                  value: student.completed,
                  onChanged: (value) {
                    db.updateTaskCompletion(widget.task.id, student.id, value);
                  },
                ),
                Checkbox(
                  value: student.verified,
                  onChanged: (value) {
                    db.updateTaskVerification(widget.task.id, student.id, value);
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  Future<Null> _refresh() async {
    await Future.microtask(() => setState(() {
      _students = db.getTaskCompletionSnapshots(widget.task.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: _actionMenuBuilder,
            onSelected: _onActionMenuSelected,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 3/2,
                child: Container(),
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
                        stream: _students,
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

        },
      ),
    );
  }
}