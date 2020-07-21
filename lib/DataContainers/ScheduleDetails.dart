class ScheduleDetails {
  String id;
  String taskId;
  String taskName;
  DateTime scheduledDate;
  DateTime startTime;
  DateTime endTime;
  int startId;
  int endId;

  ScheduleDetails({
    String id,
    String taskId,
    String taskName,
    DateTime scheduledDate,
    DateTime startTime,
    DateTime endTime,
    int startId,
    int endId
  }) :  this.id = id,
        this.taskId = taskId,
        this.taskName= taskName,
        this.scheduledDate = scheduledDate,
        this.startTime = startTime,
        this.endTime = endTime,
        this.startId = startId,
        this.endId = endId;

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    map["taskName"] = this.taskName;
    map["taskId"] = this.taskId;
    map["scheduledDate"] = this.scheduledDate;
    map["startTime"] = this.startTime;
    map["endTime"] = this.endTime;
    if (this.startId != null) map["startId"] = this.startId;
    if (this.endId != null) map["endId"] = this.endId;
    return map;
  }

  ScheduleDetails addNotifIds(int startId, int endId) {
    this.startId = startId;
    this.endId = endId;
    return this;
  }
}