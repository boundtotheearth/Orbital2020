import 'package:flutter/cupertino.dart';
import 'package:orbital2020/Task.dart';

class TaskWithStatus extends Task{
  bool completed;
  bool verified;

  TaskWithStatus({
    @required String name,
    String description,
    String createdBy,
    DateTime dueDate,
    List<String> tags = const [],
    bool completed,
    bool verified
  }) :
    this.completed = completed ?? false,
    this.verified = verified ?? false,
    super(name: name, description: description, createdBy: createdBy, dueDate: dueDate, tags: tags);

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = super.toKeyValuePair();
    if(completed != null) map['completed'] = completed;
    if(verified != null) map['verified'] = verified;
    return map;
  }
}