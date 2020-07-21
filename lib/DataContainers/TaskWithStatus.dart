import 'package:orbital2020/DataContainers/Task.dart';

//Contains data related to the completion status of a task in addition to the task details
class TaskWithStatus extends Task{
  bool completed;
  bool verified;
  bool claimed;

  TaskWithStatus({
    String id,
    String name = '',
    String description = '',
    String createdByName = '',
    String createdById,
    DateTime dueDate,
    List<String> tags = const [],
    bool completed,
    bool verified,
    bool claimed
  }) :
    this.completed = completed ?? false,
    this.verified = verified ?? false,
    this.claimed = claimed ?? false,
    super(id: id, name: name, description: description, createdByName: createdByName, createdById: createdById, dueDate: dueDate, tags: tags);

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = super.toKeyValuePair();
    if(completed != null) map['completed'] = completed;
    if(verified != null) map['verified'] = verified;
    if (claimed != null) map['claimed'] = claimed;
    return map;
  }

  int getStatus() {
    if (!completed) {
      return 0;
    } else if (!verified) {
      return 1;
    } else if (!claimed) {
      return 2;
    } else {
      return 3;
    }
  }

  int getStatusTeacher(String teacherId) {
    if (teacherId != createdById) {
      return 3;
    } else if (!completed) {
      return 0;
    } else if (!verified) {
      return 1;
    } else {
      return 2;
    }
  }
}