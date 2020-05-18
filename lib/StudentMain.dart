import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/StudentAddTask.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';

import 'AppDrawer.dart';


class StudentMain extends StatefulWidget {
  StudentMain({Key key}) : super(key: key);

  @override
  _StudentMainState createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  final DatabaseController db = DatabaseController();

  UnityWidgetController _unityWidgetController;
  Stream<List<TaskWithStatus>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = db.getStudentTaskSnapshots(studentId: 'Rsd56J6FqHEFFg12Uf3M');
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
            subtitle: Text(task.createdBy),
            trailing: Wrap(
              children: <Widget>[
                Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    db.updateTaskCompletion(task.id, 'Rsd56J6FqHEFFg12Uf3M', value);
                  },
                ),
                Checkbox(
                  value: task.verified,
                  onChanged: (value) {
                    db.updateTaskVerification(task.id, 'Rsd56J6FqHEFFg12Uf3M', value);
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
      _tasks = db.getStudentTaskSnapshots(studentId: 'Rsd56J6FqHEFFg12Uf3M');
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppName'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {},
          )
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
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentAddTask())
          );
        },
      ),
    );
  }
}

class MockTask {
  String name;
  bool completed;
  bool verified;

  MockTask(this.name, this.completed, this.verified);

}