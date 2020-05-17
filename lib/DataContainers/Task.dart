import 'package:orbital2020/DataContainers/TaskWithStatus.dart';

//Contains data on a specific task and operations to convert the data into a database friendly format.
class Task {
  String id;
  String name;
  String description;
  String createdBy;
  DateTime dueDate;
  List<String> tags;

  Task({
    this.id,
    this.name,
    this.description,
    this.createdBy,
    this.dueDate,
    this.tags = const [],
  });

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    map['name'] = name;
    if(description != null) map['description'] = description;
    if(createdBy != null) map['createdBy'] = createdBy;
    if(dueDate != null) map['dueDate'] = dueDate;
    if(tags.isNotEmpty) map['tags'] = tags;
    return map;
  }

  TaskWithStatus addStatus(bool completed, bool verified) {
    return TaskWithStatus(
      id: id,
      name: name,
      description: description,
      createdBy: createdBy,
      dueDate: dueDate,
      tags: tags,
      completed: completed,
      verified: verified
    );
  }
}