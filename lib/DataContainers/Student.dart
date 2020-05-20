import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/StudentWithStatus.dart';

//A student is a group with 1 member.
class Student extends Group {
  Student({String id, String name}) : super(id: id, name: name);

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