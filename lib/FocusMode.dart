import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orbital2020/AppDrawer.dart';
import 'package:orbital2020/DataContainers/FocusSession.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/FocusHistoryChart.dart';
import 'package:provider/provider.dart';
import 'package:screen_state/screen_state.dart';

class FocusMode extends StatefulWidget {
  FocusMode({Key key});

  @override
  _FocusModeStatus createState() => new _FocusModeStatus();
}

class _FocusModeStatus extends State<FocusMode> {

  bool _inFocus;
  Stream<FocusSession> _prevSession;

  WidgetsBindingObserver focusObserver;
  DatabaseController db;
  User _user;

  Screen _screen;
  StreamSubscription _subscription;
  ScreenStateEvent screenStateEvent = ScreenStateEvent.SCREEN_ON;

  FocusSession currentSession;
  DateTime startTime;

  @override
  void initState() {
    super.initState();
    print("initstate");
    _user = Provider.of<User>(context, listen: false);
    db = Provider.of<DatabaseController>(context, listen: false);
    _prevSession = db.getPrevFocusSessionSnapshots(studentId: _user.id);
    focusObserver = FocusManager(
      detachedCallBack: () => {},
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
    if(currentSession != null && currentSession.focusStatus == FocusStatus.ONGOING) {
      if(event == ScreenStateEvent.SCREEN_ON) {
        currentSession.onWake();
        db.updateFocusSession(studentId: _user.id, focusSession: currentSession);
      } else if(event == ScreenStateEvent.SCREEN_OFF) {
        currentSession.onSleep();
        db.updateFocusSession(studentId: _user.id, focusSession: currentSession);
      }
    }
  }

  @override
  void dispose() {
    print('dispose');
    WidgetsBinding.instance.removeObserver(focusObserver);
    _subscription?.cancel();
    super.dispose();
  }

  void resumeFocus(FocusSession session) {
    _inFocus = true;
    currentSession = session;
    currentSession.didSleep = false;
    db.updateFocusSession(studentId: _user.id, focusSession: currentSession);
  }

  void startFocus() {
    currentSession = FocusSession();
    currentSession.start();
    setState(() {
        _inFocus = true;
    });
    db.addFocusSession(studentId: _user.id, focusSession: currentSession);
  }

  void interruptFocus() {
    Future.delayed(Duration(milliseconds: 5000), () {
      print("Checking: " + screenStateEvent.toString());
      if(screenStateEvent == ScreenStateEvent.SCREEN_ON) {
        immediateInterruptFocus();
      }
    });
  }

  void immediateInterruptFocus() {
    currentSession.interrupt();
    endFocus();
  }

  void stopFocus() {
    currentSession.stop();
    endFocus();
  }

  void endFocus() {
    _inFocus = false;
    db.updateFocusSession(studentId: _user.id, focusSession: currentSession);
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

  Widget buildDefaultUI(FocusSession prevFocusSession) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: const Text('Focus Mode'),
        ),
        body: ListView(
          children: <Widget>[
            Text(prevFocusSession.focusStatus == FocusStatus.INTERRUPTED
                ? 'Your previous focus session was interrupted!'
                : 'In focus mode, your plants will grow and produce gems. Leaving the app or going to another page will end focus mode. You can lock your phone without interrupting focus mode'
            ),
            Text('Go back to the game to claim your rewards!'),
            StreamBuilder(
              stream: db.getFocusSessionHistory(studentId: _user.id, days: 7),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return FocusHistoryChart(snapshot.data);
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Text('Previous Focus Duration: ${prevFocusSession.durationMins}'),
            RaisedButton(
              child: const Text('Start Focus Mode', textAlign: TextAlign.center),
              onPressed: startFocus,
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _prevSession,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          FocusSession session = snapshot.data;
          if(session.focusStatus == FocusStatus.ONGOING) {
            currentSession = session;
            if(session.didSleep || _inFocus) {
              resumeFocus(currentSession);
              return buildFocusUI();
            }
            immediateInterruptFocus();
          }
          return buildDefaultUI(snapshot.data);


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