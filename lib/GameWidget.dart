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

  WidgetsBindingObserver appObserver;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    appObserver = GameDataManager(
      detachedCallBack: () => _saveGameData(),
      inactiveCallback: () => _saveGameData(),
      pauseCallback: () => _saveGameData(),
      resumeCallBack: () => _setGameData(),
    );
    WidgetsBinding.instance.addObserver(appObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(appObserver);
    super.dispose();
  }

  void _onUnityCreated(controller) async {
    this._unityWidgetController = controller;
    _setGameData();
  }

  void _onUnityMessage(controller, message) async {
    latestGameData = message;
  }

  void _setGameData() async {
    Map<String, dynamic> data = await db.fetchGameData(studentId: _user.id);
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