
class TaskStatus {
  String id;
  String name;
  bool completed;
  bool verified;
  bool claimed;

  TaskStatus({String id, String name, bool completed, bool verified, bool claimed}) {
    this.id = id;
    this.name = name;
    this.completed = completed;
    this.verified = verified;
    this.claimed = claimed;
  }

  TaskStatus setName(String name) {
    return TaskStatus(id: this.id, name: name, completed: this.completed, verified: this.verified);
  }

  Map<String, bool> toKeyValuePair() {
    Map<String, bool> map = Map();
    map["completed"] = this.completed;
    map["verified"] = this.verified;
    map["claimed"] = this.claimed;
    return map;
  }
}