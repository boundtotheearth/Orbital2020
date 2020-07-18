import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';
import 'package:screen_state/screen_state.dart';

class FocusMode extends StatefulWidget {
  FocusMode({Key key});

  @override
  _FocusModeStatus createState() => new _FocusModeStatus();
}

class _FocusModeStatus extends State<FocusMode> {

  bool _inFocus;
  Stream<bool> _prevInFocus;

  WidgetsBindingObserver focusObserver;
  DatabaseController db;
  User _user;

  String temp = "Nothing";
  Screen _screen;
  StreamSubscription _subscription;
  ScreenStateEvent screenStateEvent = ScreenStateEvent.SCREEN_ON;

  @override
  void initState() {
    super.initState();
    print("initstate");
    _user = Provider.of<User>(context, listen: false);
    db = Provider.of<DatabaseController>(context, listen: false);
    _prevInFocus = db.getStudentFocus(_user.id);
    focusObserver = FocusManager(
      detachedCallBack: interruptFocus,
      inactiveCallback: interruptFocus,
      pauseCallback: interruptFocus,
      resumeCallBack: () => {},
    );
    WidgetsBinding.instance.addObserver(focusObserver);

    _inFocus = false;
    _screen = new Screen();
    try {
      _subscription = _screen.screenStateStream.listen(onData);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  void onData(ScreenStateEvent event) {
    print("OnData " + event.toString());
    setState(() {
      screenStateEvent = event;
    });
  }

  @override
  void dispose() {
    print('dispose');
    WidgetsBinding.instance.removeObserver(focusObserver);
    _subscription?.cancel();
    super.dispose();
  }

  void interruptFocus() {
    Future.delayed(Duration(milliseconds: 4000), () {
      print("Checking: " + screenStateEvent.toString());
      if(screenStateEvent == ScreenStateEvent.SCREEN_ON) {
        setState(() {
          _inFocus = false;
        });
      }
    });
  }

  void stopFocus() {
    setState(() {
      _inFocus = false;
    });
    db.setStudentFocus(_user.id, false);
  }

  Widget buildFocusUI() {
    return Container(
      color: Colors.white10,
      child: RaisedButton(
        child: const Text("End Focus Mode"),
        onPressed: stopFocus,
      ),
    );
  }

  Widget buildDefaultUI(bool prevFocusStatus) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: const Text('Focus Mode'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(prevFocusStatus
                ? 'Your previous focus session was interrupted!'
                : 'In focus mode, your plants will grow and produce gems. Leaving the app or going to another page will end focus mode. You can lock your phone without interrupting focus mode'
            ),
            RaisedButton(
              child: const Text('Start Focus Mode', textAlign: TextAlign.center),
              onPressed: () {
                setState(() {
                  _inFocus = true;
                  db.setStudentFocus(_user.id, true);
                });
              },
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _prevInFocus,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(_inFocus) {
            return buildFocusUI();
          } else {
            return buildDefaultUI(snapshot.data);
          }
        } else {
          return Container();
        }
      },
    );
  }
}

typedef FutureVoidCallback();

class FocusManager extends WidgetsBindingObserver {
  FocusManager({this.resumeCallBack, this.detachedCallBack, this.inactiveCallback, this.pauseCallback});

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