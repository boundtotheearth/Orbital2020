import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import 'AppDrawer.dart';


class StudentMain extends StatefulWidget {
  StudentMain({Key key}) : super(key: key);

  @override
  _StudentMainState createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  UnityWidgetController _unityWidgetController;
  List<MockTask> tasks = [
    MockTask('task 1', false, false),
    MockTask('task 2', true, false),
    MockTask('task 3', true, true),
    MockTask('task 4', true, true),
    MockTask('task 5', true, true),
    MockTask('task 6', true, true),
    MockTask('task 7', true, true),
    MockTask('task 8', true, true),
    MockTask('task 9', true, true),
    MockTask('task 10', true, true),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter(String amount) {
    print("increment");
    _unityWidgetController.postMessage('FlutterMessageReceiver', 'Increment', amount);
  }

  void onUnityCreated(controller) {
    this._unityWidgetController = controller;
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 3));
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
            onPressed: () {

            },
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
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(tasks[index].name),
                          subtitle: Text("Ms Lee (Math)"),
                          trailing: Wrap(
                            children: <Widget>[
                              Checkbox(
                                value: tasks[index].completed,
                                onChanged: (value) {},
                              ),
                              Checkbox(
                                value: tasks[index].verified,
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        );
                      }
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