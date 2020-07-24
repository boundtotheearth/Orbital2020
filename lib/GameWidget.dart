import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:orbital2020/DataContainers/FocusSession.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

class GameWidget extends StatefulWidget {
  static final unityWidgetKey = GlobalKey<GameWidgetState>();
  GameWidget() : super(key: unityWidgetKey);

  @override
  GameWidgetState createState() => GameWidgetState();
}

class GameWidgetState extends State<GameWidget> {
  final DatabaseController db = DatabaseController();
  User _user;
  UnityWidgetController _unityWidgetController;
  String latestGameData;

  Stream<Map<String, dynamic>> gameDataStream;
  StreamSubscription gameDataSub;
  Stream<List<FocusSession>> focusSessionStream;
  StreamSubscription focusSessionSub;

  WidgetsBindingObserver appObserver;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
  }

  @override
  void dispose() {
    gameDataSub?.cancel();
    focusSessionSub?.cancel();
    super.dispose();
  }

  void _onUnityCreated(controller) async {
    this._unityWidgetController = controller;
    Map<String, dynamic> data = await db.fetchGameData(studentId: _user.id);
    _setGameData(data);
    focusSessionStream = db.getUnclaimedFocusSession(studentId: _user.id);
    focusSessionSub = focusSessionStream.listen(_handleFocusTime);
    //_setGameData();
  }

  void _onUnityMessage(controller, message) async {
    if(mounted) {
      latestGameData = message;
      _saveGameData();
    }
  }

  void resetGame() {
    _unityWidgetController?.postMessage("GameField", "resetGame", "");
  }

  void _setGameData(Map<String, dynamic> data) {
    data.remove('timestamp');
    String gameData = data != null ? jsonEncode(data) : "";
    _unityWidgetController?.postMessage("GameField", "setGameData", gameData);
    latestGameData = gameData;
  }

  void _handleFocusTime(List<FocusSession> sessions) {
    int totalFocus = 0;
    for(FocusSession session in sessions) {
      if(session.focusStatus != FocusStatus.ONGOING) {
        totalFocus += session.durationMins;
        session.claimed = true;
        db.updateFocusSession(studentId: _user.id, focusSession: session);
      }
    }
    _unityWidgetController?.postMessage("GameField", "handleFocusTime", totalFocus.toString());
  }

  void _saveGameData() {
    if(latestGameData != null) {
      Map<String, dynamic> data = jsonDecode(latestGameData);
      data['timestamp'] = DateTime.now();
      db.saveGameData(data: data, studentId: _user.id);
    }
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