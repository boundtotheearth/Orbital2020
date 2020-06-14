import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

class GameWidget extends StatefulWidget {
  GameWidget({Key key}) : super(key: key);

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {

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
      resumeCallBack: () => {},
    ));
  }

  void _onUnityCreated(controller) async {
    this._unityWidgetController = controller;
    String gameData = await db.fetchGameData(studentId: _user.id);
    _unityWidgetController.postMessage("GameField", "setGameData", gameData);
    latestGameData = gameData;
  }

  void _onUnityMessage(controller, message) async {
    latestGameData = message;
    print(latestGameData);
    //db.saveGameData(data: message, studentId: _user.id);
  }

  void _saveGameData() {
    db.saveGameData(data: latestGameData, studentId: _user.id);
    print(latestGameData);
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