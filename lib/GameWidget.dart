import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

class GameWidget extends StatefulWidget {
  GameWidget({Key key}) : super(key: key);

  @override
  GameWidgetState createState() => GameWidgetState();
}

class GameWidgetState extends State<GameWidget> {

  final DatabaseController db = DatabaseController();
  User _user;
  UnityWidgetController _unityWidgetController;
  String latestGameData;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    WidgetsBinding.instance.addObserver(GameDataManager(
      detachedCallBack: () => _saveGameData(),
      inactiveCallback: () => {},
      pauseCallback: () => _saveGameData(),
      resumeCallBack: () => _setGameData(),
    ));
  }

  void _onUnityCreated(controller) async {
    this._unityWidgetController = controller;
    _setGameData();
  }

  void _onUnityMessage(controller, message) async {
    latestGameData = message;
    //print(latestGameData);
    //db.saveGameData(data: message, studentId: _user.id);
  }

  void _setGameData() async {
    Map<String, dynamic> data = await db.fetchGameData(studentId: _user.id);
    //data['idle'] = await _calculateIdleTime(data['timestamp'].toDate()).then((value) => value.inSeconds);
    data.remove('timestamp');
    String gameData = data != null ? jsonEncode(data) : "";
    _unityWidgetController.postMessage("GameField", "setGameData", gameData);
    latestGameData = gameData;
  }

  void _saveGameData() {
    Map<String, dynamic> data = jsonDecode(latestGameData);
    data['timestamp'] = DateTime.now();
    db.saveGameData(data: data, studentId: _user.id);
  }

//  Future<Duration> _calculateIdleTime(DateTime lastActive) async {
//    DateTime currentTime = DateTime.now();
//    Duration totalIdle = currentTime.difference(lastActive);
//    print("last active " + lastActive.toString());
//    print("before " + totalIdle.toString());
//
//
//    if(totalIdle.inSeconds < (15 * 60)) {
//      return Future.value(Duration(seconds: 0));
//    }
//
//    AppUsage appUsage = new AppUsage();
//    try {
//      Map<String, double> usage = await appUsage.fetchUsage(lastActive, currentTime);
//      usage.removeWhere((key,val) => val == 0);
//
//      print(usage);
//
//      for(MapEntry<String, double> entry in usage.entries) {
//        Duration appDuration = Duration(seconds: entry.value.toInt());
//        totalIdle = totalIdle - appDuration;
//        print(entry.key);
//        print('app ' + appDuration.toString());
//        print('step ' + totalIdle.toString());
//      }
//      print("after " + totalIdle.toString());
//      return totalIdle;
//    }
//    on AppUsageException catch (exception) {
//      print(exception);
//      return Future.error(exception);
//    }
//  }

  void giveReward(int amount) {
    _unityWidgetController.postMessage('GameField', 'giveReward', amount.toString());
  }

  Future<Widget> _unityWidgetBuilder() async {
    return UnityWidget(
      onUnityViewCreated: _onUnityCreated,
      onUnityMessage: _onUnityMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _unityWidgetBuilder(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return snapshot.data;
        } else {
          return Container();
        }
      },
    );
  }
}

typedef FutureVoidCallback();

class GameDataManager extends WidgetsBindingObserver {
  GameDataManager({this.resumeCallBack, this.detachedCallBack, this.inactiveCallback, this.pauseCallback});

  final FutureVoidCallback resumeCallBack;
  final FutureVoidCallback detachedCallBack;
  final FutureVoidCallback inactiveCallback;
  final FutureVoidCallback pauseCallback;

//  @override
//  Future<bool> didPopRoute()

//  @override
//  void didHaveMemoryPressure()

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        await inactiveCallback();
        break;
      case AppLifecycleState.paused:
        await pauseCallback();
        break;
      case AppLifecycleState.detached:
        await detachedCallBack();
        break;
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
  }
}