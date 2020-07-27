import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/FocusSession.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/FocusHistoryChart.dart';
import 'package:orbital2020/StudentAppDrawer.dart';
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

  bool _interrupt;

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
      resumeCallBack: cancelInterrupt,
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

  void resumeFocus(FocusSession session) {
    _inFocus = true;
    currentSession = session;
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
    _interrupt = true;
    Future.delayed(Duration(seconds: 5)).then((value) {
      if(_interrupt && screenStateEvent == ScreenStateEvent.SCREEN_ON) {
        print(screenStateEvent);
        print("interrupt");
        _inFocus = false;
        currentSession.interrupt();
        db.updateFocusSession(studentId: _user.id, focusSession: currentSession);
      }
    });
  }

  void cancelInterrupt() {
    _interrupt = false;
  }

  void stopFocus() {
    currentSession.stop();
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
        drawer: StudentAppDrawer(),
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
                  return Center(child :CircularProgressIndicator());
                }
              },
            ),
            Text('Previous Focus Duration: ${prevFocusSession.durationMins} mins'),
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
            resumeFocus(session);
            return buildFocusUI();
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