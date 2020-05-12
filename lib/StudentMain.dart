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