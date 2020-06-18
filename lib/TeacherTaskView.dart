import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/StudentWithStatus.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/StudentStatusTile.dart';
import 'package:orbital2020/TaskProgressIndicator.dart';
import 'package:provider/provider.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:rxdart/rxdart.dart';
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


  Stream<List<Student>> _students;
  User _user;
  String _searchText;
  bool _searchBarActive;

  @override
  void initState() {
    super.initState();
    _students = db.getStudentsWithTask(widget.task.id);
    _user = Provider.of<User>(context, listen: false);
    _searchText = '';
    _searchBarActive = false;
  }

  bool filtered(String studentName) {
    return studentName.toLowerCase().startsWith(_searchText);
  }

  Widget _buildStudentList(List<Student> students) {

    return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          Student student = students[index];
          //get task status stream for that student
          return StreamBuilder<TaskStatus>(
            stream: db.getStudentTaskStatus(student.id, widget.task.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && filtered(student.name)) {
                return StudentStatusTile(
                student: student.addStatus(snapshot.data.completed, snapshot.data.verified),
                isStudent: _user.accountType == 'student',
                updateComplete: (value) {
                  db.updateTaskCompletion(widget.task.id, student.id, value);
                },
                updateVerify: (value) {
                  db.updateTaskVerification(widget.task.id, student.id, value);
                },
                onFinish: () {},
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
      _students = db.getStudentsWithTask(widget.task.id);
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
              StreamBuilder(
                stream: _students,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    List<Stream<TaskStatus>> streamList = [];
                    snapshot.data.forEach((Student student) {
                      streamList.add(db.getStudentTaskStatus(student.id, widget.task.id));
                    });

                    return StreamBuilder<List<TaskStatus>>(
                      stream: CombineLatestStream.list(streamList),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int total = snapshot.data.length;
                          int completed = snapshot.data.where((task) => task.completed).length;
                          return AspectRatio(
                            aspectRatio: 3 / 2,
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: CustomPaint(
                                  foregroundPainter: TaskProgressIndicator(total > 0 ?
                                      completed / total
                                      : 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("$completed/$total",
                                        style: TextStyle(fontSize: 28,
                                            fontWeight: FontWeight.bold),),
                                      Text("Completed",
                                        style: TextStyle(fontSize: 20),)
                                    ],
                                  ),
                                )
                            ),
                          );
                        } else {
                          return ListTile(
                            title: CircularProgressIndicator(),
                          );
                        }
                      }
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              Text(widget.task.description ?? "No Description"),
              Text("Due: " + DateFormat('dd/MM/y').format(widget.task.dueDate)),
              Text('Tags:'),
              Wrap(
                spacing: 8.0,
                children: getTagChips(),
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