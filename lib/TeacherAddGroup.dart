import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning a task to a student
class TeacherAddGroup extends StatefulWidget {

  TeacherAddGroup({Key key}) : super(key: key);


  @override
  _TeacherAddGroupState createState() => _TeacherAddGroupState();
}

class _TeacherAddGroupState extends State<TeacherAddGroup> {
  final DatabaseController db = DatabaseController();

  User _user;

  Stream<List<Student>> _allStudents;
  Set<Student> _students;
  String _groupName;
  String _searchText;


  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _allStudents = db.getAllStudentsSnapshots();
    _students = Set();
    _searchText = "";
  }

  List<Widget> buildChips() {
    List<Widget> studentChips = <Widget>[];
    for(Student student in _students) {
      studentChips.add(Chip(
        label: Text(student.name),
        onDeleted: () {
          deleteStudent(student);
        },
      ));
    }
    return studentChips;
  }

  void deleteStudent(Student student) {
    setState(() {
      _students.remove(student);
    });
  }

  void addStudent(Student student) {
    setState(() {
      _students.add(student);
    });
  }

  Widget buildSuggestions() {
    return StreamBuilder(
      stream: _allStudents,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          List<Student> allStudents = snapshot.data;
          List<Student> suggestions = allStudents.where((element) =>
              element.name.startsWith(_searchText)).toList();
          return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                Student student = suggestions[index];
                return ListTile(
                  title: Text(student.name),
                  onTap: () {
                    addStudent(student);
                  },
                );
              }
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> submitGroup() {
    Group newGroup = Group(name: _groupName, students: _students);
    return db.teacherCreateGroup(teacherId: _user.id, group: newGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.group),
                  labelText: 'Group Name',
                ),
                onChanged: (value) {
                  setState(() {
                    _groupName = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Add Students',
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
              Wrap(
                children: buildChips(),
              ),
              Expanded(
                child: buildSuggestions(),
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: 'Add New Group',
        onPressed: () {
          submitGroup()
              .then((value) => Navigator.pop(context));
        },
      ),
    );
  }
}