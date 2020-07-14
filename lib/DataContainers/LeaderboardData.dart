class LeaderboardData {
  String id;
  String name;
  int gemTotal;

  LeaderboardData({this.id, this.name, this.gemTotal});

  Map<String, dynamic> toKeyValuePair() {
    Map<String, dynamic> map = Map();
    if(name != null) map['name'] = name;
    if(gemTotal != null) map['gemTotal'] = gemTotal;
    return map;
  }
}