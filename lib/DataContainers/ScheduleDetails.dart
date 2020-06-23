class ScheduleDetails {
  String id;
  String taskId;
  DateTime scheduledDate;
  DateTime startTime;
  DateTime endTime;

  ScheduleDetails({
    String id,
    String taskId,
    DateTime scheduledDate,
    DateTime startTime,
    DateTime endTime,
  }) :  this.id = id,
        this.taskId = taskId,
        this.scheduledDate = scheduledDate,
        this.startTime = startTime,
        this.endTime = endTime;

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    map["taskId"] = this.taskId;
    map["scheduledDate"] = this.scheduledDate;
    map["startTime"] = this.startTime;
    map["endTime"] = this.endTime;
    return map;
  }
}