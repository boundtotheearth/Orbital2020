class User {
  String id;
  String name;
  String email;
  String accountType;
  String photoUrl;

  User({this.id, this.name, this.email, this.accountType, this.photoUrl});

  @override
  String toString() {
    return id;
  }
}