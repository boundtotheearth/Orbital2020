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

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
  }

  void _onUnityCreated(controller) async {
    this._unityWidgetController = controller;
    String gameData = await db.fetchGameData(studentId: _user.id);
    _unityWidgetController.postMessage("GameField", "setGameData", gameData);
  }

  void _onUnityMessage(controller, message) async {
    await db.saveGameData(data: message, studentId: _user.id);
    String fetchedData = await db.fetchGameData(studentId: _user.id);
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