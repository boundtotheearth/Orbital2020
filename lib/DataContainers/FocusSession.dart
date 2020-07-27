import 'package:flutter/foundation.dart';

enum FocusStatus {
  ONGOING,
  COMPLETED,
  INTERRUPTED,
}

class FocusSession {
  String id;
  DateTime startTime;
  DateTime endTime;
  int durationMins = 0;
  FocusStatus focusStatus = FocusStatus.COMPLETED;
  bool claimed = false;

  FocusSession();
  FocusSession.fromKeyValuePair(Map<String, dynamic> map) {
    this.id = map['id'];
    this.startTime = map['startTime']?.toDate();
    this.endTime = map['endTime']?.toDate();
    this.durationMins = map['durationMins'];
    if(map['focusStatus'] != null) {
      switch(map['focusStatus']) {
        case 'ONGOING':
          this.focusStatus = FocusStatus.ONGOING;
          break;
        case 'COMPLETED':
          this.focusStatus = FocusStatus.COMPLETED;
          break;
        case 'INTERRUPTED':
          this.focusStatus = FocusStatus.INTERRUPTED;
          break;
        default:
          break;
      }
    } else {
      this.focusStatus = null;
    }

    this.claimed = map['claimed'];
  }

  void start() {
    startTime = DateTime.now();
    focusStatus = FocusStatus.ONGOING;
  }

  void stop() {
    endTime = DateTime.now();
    focusStatus = FocusStatus.COMPLETED;
    durationMins = endTime.difference(startTime).inMinutes;
  }

  void resume() {
    endTime = null;
    focusStatus = FocusStatus.ONGOING;
  }

  void interrupt() {
    endTime = DateTime.now();
    focusStatus = FocusStatus.INTERRUPTED;
    durationMins = endTime.difference(startTime).inMinutes;
  }

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(id != null) map['id'] = id;
    if(startTime != null) map['startTime'] = startTime;
    if(endTime != null) map['endTime'] = endTime;
    if(durationMins != null) map['durationMins'] = durationMins;
    if(focusStatus != null) map['focusStatus'] = describeEnum(focusStatus);
    if(claimed != null) map['claimed'] = claimed;
    return map;
  }

  @override
  String toString() {
    return this.toKeyValuePair().toString();
  }
}