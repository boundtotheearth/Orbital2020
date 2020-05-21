import 'package:orbital2020/DataContainers/StudentWithStatus.dart';

//A student is a group with 1 member.
class Student {
  final String id;
  final String name;

  Student({this.id, this.name});

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(name != null) map['name'] = name;
    return map;
  }

  StudentWithStatus addStatus(bool completed, bool verified) {
    return StudentWithStatus(
        id: id,
        name: name,
        completed: completed,
        verified: verified
    );
  }

  @override
  bool operator ==(other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is Student
        && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}