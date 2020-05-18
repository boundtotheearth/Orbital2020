import 'package:orbital2020/DataContainers/StudentWithStatus.dart';

class Student {
  String id;
  String name;

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
}