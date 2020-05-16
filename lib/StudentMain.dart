import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/StudentAddTask.dart';
import 'package:orbital2020/TaskWithStatus.dart';

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
    _tasks = db.getStudentTaskSnapshots('Rsd56J6FqHEFFg12Uf3M');
  }

  void _incrementCounter(String amount) {
    print("increment");
    _unityWidgetController.postMessage('FlutterMessageReceiver', 'Increment', amount);
  }

  void onUnityCreated(controller) {
    this._unityWidgetController = controller;
  }

  Widget _buildTaskList(List<TaskWithStatus> tasks) {
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          TaskWithStatus task = tasks[index];
          print(task.name);
          return ListTile(
            title: Text(task.name),
            subtitle: Text(task.createdBy),
            trailing: Wrap(
              children: <Widget>[
                Checkbox(
                  value: task.completed,
                  onChanged: (value) {},
                ),
                Checkbox(
                  value: task.verified,
                  onChanged: (value) {},
                ),
              ],
            ),
          );
        }
    );
  }

  Future<Null> refresh() async {
    await Future.microtask(() => setState(() {
      _tasks = db.getStudentTaskSnapshots('Rsd56J6FqHEFFg12Uf3M');
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
              Container(
                height: 300,
                child: UnityWidget(
                  onUnityViewCreated: onUnityCreated,
                ),
              ),
              Row(
                children: <Widget>[
                  Text('Sort By: //Dropdown Here'),
                  //dropdown menu
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
                          return _buildTaskList(snapshot.data);
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