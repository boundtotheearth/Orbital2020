import 'package:orbital2020/DataContainers/Student.dart';

class Group {
  String id;
  String name;
  String createdById;
  Set<Student> students;

  Group({this.id, this.name, this.createdById, this.students});

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(name != null) map['name'] = name;
    if(createdById != null) map['createdById'] = createdById;
    return map;
  }
}