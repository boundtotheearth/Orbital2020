import 'package:orbital2020/DataContainers/Task.dart';

//Contains data related to the completion status of a task in addition to the task details
class TaskWithStatus extends Task{
  bool completed;
  bool verified;

  TaskWithStatus({
    String id,
    String name = '',
    String description = '',
    String createdByName = '',
    String createdById,
    DateTime dueDate,
    List<String> tags = const [],
    bool completed,
    bool verified
  }) :
    this.completed = completed ?? false,
    this.verified = verified ?? false,
    super(id: id, name: name, description: description, createdByName: createdByName, createdById: createdById, dueDate: dueDate, tags: tags);

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = super.toKeyValuePair();
    if(completed != null) map['completed'] = completed;
    if(verified != null) map['verified'] = verified;
    return map;
  }

  int getStatus() {
    if (!completed) {
      return 0;
    } else if (!verified) {
      return 1;
    } else {
      return 2;
    }
  }
}