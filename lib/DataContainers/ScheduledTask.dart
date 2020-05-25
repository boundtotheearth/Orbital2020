
class ScheduledTask {

  String id;
  String name;
  DateTime scheduledDate;
  DateTime startTime;
  DateTime endTime;

  ScheduledTask({
    String id,
    String name,
    DateTime scheduledDate,
    DateTime startTime,
    DateTime endTime,
  }) :
        this.id = id,
        this.name = name,
        this.scheduledDate = scheduledDate,
        this.startTime = startTime,
        this.endTime = endTime;

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    map["name"] = this.name;
    map["scheduledDate"] = this.scheduledDate;
    map["startTime"] = this.startTime;
    map["endTime"] = this.endTime;
    return map;
  }

}