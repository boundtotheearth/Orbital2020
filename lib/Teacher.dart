class Teacher {
  String id;
  String name;

  Teacher({this.id, this.name});

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(name != null) map['name'] = name;
    return map;
  }
}