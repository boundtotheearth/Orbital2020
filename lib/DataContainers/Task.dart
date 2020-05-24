import 'package:orbital2020/DataContainers/TaskWithStatus.dart';

//Contains data on a specific task and operations to convert the data into a database friendly format.
class Task {
  String id;
  String name;
  String description;
  String createdByName;
  String createdById;
  DateTime dueDate;
  List<String> tags;

  Task({
    this.id,
    this.name,
    this.description,
    this.createdByName,
    this.createdById,
    this.dueDate,
    this.tags = const [],
  });

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(name != null) map['name'] = name;
    if(description != null) map['description'] = description;
    if(createdByName != null) map['createdByName'] = createdByName;
    if(createdById != null) map['createdById'] = createdById;
    if(dueDate != null) map['dueDate'] = dueDate;
    if(tags.isNotEmpty) map['tags'] = tags;
    return map;
  }

  TaskWithStatus addStatus(bool completed, bool verified) {
    return TaskWithStatus(
      id: id,
      name: name,
      description: description,
      createdByName: createdByName,
      createdById: createdById,
      dueDate: dueDate,
      tags: tags,
      completed: completed,
      verified: verified
    );
  }

  @override
  bool operator ==(other) {
    if (identical(this, other))
      return true;
    return other is Task
        && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    // TODO: implement toString
    return id;
  }
}