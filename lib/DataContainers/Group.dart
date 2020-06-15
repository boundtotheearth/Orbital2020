import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';

class Group {
  String id;
  String name;
  String imageUrl;
  Set<Student> students;
  Set<Task> tasks;

  Group({this.id, this.name, this.imageUrl, this.students, this.tasks});

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(name != null) map['name'] = name;
    if(imageUrl != null) map['imageUrl'] = imageUrl;
    return map;
  }
}