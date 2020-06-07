import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning a task to a student
class TeacherAssignStudent extends StatefulWidget {
  final Task task;
  final Group group;

  TeacherAssignStudent({Key key, @required this.task, @required this.group}) : super(key: key);

  @override
  _TeacherAssignStudentState createState() => _TeacherAssignStudentState();
}

class _TeacherAssignStudentState extends State<TeacherAssignStudent> {
  final DatabaseController db = DatabaseController();

  User _user;

//  Stream<Set<Student>> _allStudents;
//  Stream<Set<String>> _allStudents;
//  Stream<Set<Student>> _alreadyAssigned;
//  Stream<List<String>> _alreadyAssigned;
  Set<Student> _students;
  String _searchText;


  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
//    _allStudents = db.getGroupStudentSnapshots(teacherId: _user.id, groupId: widget.group.id);
//    _alreadyAssigned = db.getTaskStudentSnapshots(taskId: widget.task.id);
//    _alreadyAssigned = db.getStudentsWithTask(widget.task.id);
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

  bool filtered(Student student) {
    return student.name.toLowerCase().startsWith(_searchText) &&
        !_students.contains(student);
  }

  Widget buildSuggestions() {
    return StreamBuilder<Set<String>>(
      stream: db.getStudentsUnassignedTask(_user.id, widget.group.id, widget.task.id),//_allStudents,
      builder: (context, snapshot) {
//          StreamBuilder(
//          stream: _alreadyAssigned,
//          builder: (context, alreadyAssignedSnapshot) {
//            if (allStudentsSnapshot.hasData && alreadyAssignedSnapshot.hasData) {
//              Set<Student> allStudents = allStudentsSnapshot.data;
//              Set<Student> alreadyAssigned = alreadyAssignedSnapshot.data;
//              Set<String> allStudents = allStudentsSnapshot.data;
//              Set<String> alreadyAssigned = alreadyAssignedSnapshot.data.toSet();

//              List<Student> suggestions = allStudents.where((element) =>
//              element.name.startsWith(_searchText)
//                  && !alreadyAssigned.contains(element)
//                  && !_students.contains(element)).toList();

//              return ListView.builder(
//                  itemCount: suggestions.length,
//                  itemBuilder: (context, index) {
//                    Student student = suggestions[index];
//                    return ListTile(
//                      title: Text(student.name),
//                      onTap: () {
//                        addStudent(student);
//                      },
//                    );
//                  }
//              );
          if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    String studentId = snapshot.data.elementAt(index);
                    return StreamBuilder<String>(
                      stream: db.getUserName(studentId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && filtered(Student(id: studentId, name: snapshot.data))) {
                          return ListTile(
                            title: Text(snapshot.data),
                            onTap: () {
                              addStudent(Student(id: studentId, name: snapshot.data));
                            },
                          );
                        } else if (snapshot.hasData) {
                          return Container(width: 0.0, height: 0.0,);
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    );
                  }
              );
            } else {
              return CircularProgressIndicator();
            }
          }
        );
  }

  Future<void> submitAssignment() {
    return db.teacherAssignStudentsToTask(_students, widget.task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign to Students'),
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
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
        tooltip: 'Add Students',
        onPressed: () {
          submitAssignment()
              .then((value) => Navigator.pop(context));
        },
      ),
    );
  }
}