import 'package:orbital2020/DataContainers/Student.dart';

class Group {
  String id;
  String name;
  List<Student> students;

  Group({this.id, this.name, this.students});

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(name != null) map['name'] = name;
    return map;
  }
}