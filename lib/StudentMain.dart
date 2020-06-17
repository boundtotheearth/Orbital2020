import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/TaskStatusTile.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'AppDrawer.dart';
import 'DataContainers/Task.dart';
import 'DataContainers/TaskStatus.dart';
import 'DataContainers/User.dart';


class StudentMain extends StatefulWidget {
  StudentMain({Key key}) : super(key: key);

  @override
  _StudentMainState createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  final DatabaseController db = DatabaseController();
  User _user;


  UnityWidgetController _unityWidgetController;
  Stream<Set<TaskStatus>> _tasks;
  String _searchText;
  bool _searchBarActive;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _tasks = db.getStudentTaskDetailsSnapshots(studentId: _user.id);
    _searchText = "";
    _searchBarActive = false;
  }

  void _incrementCounter(String amount) {
    _unityWidgetController.postMessage('FlutterMessageReceiver', 'Increment', amount);
  }

  void _onUnityCreated(controller) {
    this._unityWidgetController = controller;
  }

  Future<Widget> _unityWidgetBuilder() async {
    return UnityWidget(
      onUnityViewCreated: _onUnityCreated,
    );
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

  bool filteredTask(Task task) {
    return task.name.toLowerCase().startsWith(_searchText) ||
        (task.createdByName?.toLowerCase()?.startsWith(_searchText) ?? false);
  }

  Widget _buildTaskList(Set<TaskStatus> tasks) {
    List<TaskStatus> taskList = tasks.toList();
    return ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          TaskStatus task = taskList[index];
          return StreamBuilder<Task>(
            stream: db.getTask(task.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && filteredTask(snapshot.data)) {
                return TaskStatusTile(
                    task: snapshot.data.addStatus(task.completed, task.verified),
                    isStudent: _user.accountType == 'student',
                    updateComplete: (value) {
                      db.updateTaskCompletion(task.id, _user.id, value);
                    },
                    updateVerify: (value) {},
                    onFinish: () {},
                );
              } else if (snapshot.hasData) {
                return Container(width: 0.0, height: 0.0,);
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        }
    );

//    return StreamBuilder<List<Task>>(
//      stream: db.getTasks(taskList, "name"),
//      builder: (context, snapshot) {
//        if (snapshot.hasData) {
//          return ListView.builder(
//            itemCount: snapshot.data.length,
//            itemBuilder: (context, index) {
//              if (filteredTask(snapshot.data[index])) {
//                return TaskStatusTile(
//                  task: snapshot.data[index],
//                  isStudent: _user.accountType == "student",
//                  updateComplete: (value) {
//                    db.updateTaskCompletion(
//                        snapshot.data[index].id, _user.id, value);
//                  },
//                  updateVerify: (value) {},
//                  onFinish: () {},
//                );
//              } else {
//                return Container(width: 0.0, height: 0.0,);
//              }
//            },
//          );
//        } else {
//          return CircularProgressIndicator();
//        }
//      }
//    );


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
        title: Text('Welcome ${_user.name}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _activateSearchBar,
          ),
        ],
      );
    }
  }

  Future<Null> refresh() async {
    await Future.microtask(() => setState(() {
      _tasks = db.getStudentTaskDetailsSnapshots(studentId: _user.id);
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
                AspectRatio(
                  aspectRatio: 3/2,
                  child: FutureBuilder(
                    future: _unityWidgetBuilder(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        return snapshot.data;
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text('Sort By: //Dropdown Here'),
                    //dropdown menu
                  ],
                ),
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
                      onRefresh: refresh,
                      child: StreamBuilder<Set<TaskStatus>>(
                        stream: _tasks,
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            print(snapshot.data);
                            if(snapshot.data.length > 0) {
                              return _buildTaskList(snapshot.data);
                            } else {
                              return Text('No tasks!');
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
        tooltip: 'Add',
        onPressed: () {
          //_incrementCounter('1');
          Navigator.of(context).pushNamed('student_addTask');
        },
      ),
    );
  }
}