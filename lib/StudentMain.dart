import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:provider/provider.dart';

import 'AppDrawer.dart';


class StudentMain extends StatefulWidget {
  StudentMain({Key key}) : super(key: key);

  @override
  _StudentMainState createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  final DatabaseController db = DatabaseController();
  FirebaseUser _user;


  UnityWidgetController _unityWidgetController;
  Stream<List<TaskWithStatus>> _tasks;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<FirebaseUser>(context, listen: false);
    _tasks = db.getStudentTaskSnapshots(studentId: _user.uid);
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

  Widget _buildTaskList(List<TaskWithStatus> tasks) {
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          TaskWithStatus task = tasks[index];
          return ListTile(
            title: Text(task.name),
            subtitle: Text(task.createdByName),
            trailing: Wrap(
              children: <Widget>[
                Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    db.updateTaskCompletion(task.id, _user.uid, value);
                  },
                ),
                Checkbox(
                  value: task.verified,
                  onChanged: (value) {
                    db.updateTaskVerification(task.id, _user.uid, value);
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  Future<Null> refresh() async {
    await Future.microtask(() => setState(() {
      _tasks = db.getStudentTaskSnapshots(studentId: _user.uid);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${_user.displayName}'),
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
                      child: StreamBuilder(
                        stream: _tasks,
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
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
          _incrementCounter('1');
//          Navigator.push(
////              context,
////              MaterialPageRoute(builder: (context) => StudentAddTask())
////          );
          Navigator.of(context).pushNamed('student_addTask');
        },
      ),
    );
  }
}