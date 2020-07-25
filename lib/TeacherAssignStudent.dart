import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/LoadingDialog.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning students to a task
class TeacherAssignStudent extends StatefulWidget {
  final Task task;
  final Group group;

  TeacherAssignStudent({Key key, @required this.task, @required this.group}) : super(key: key);

  @override
  _TeacherAssignStudentState createState() => _TeacherAssignStudentState();
}

class _TeacherAssignStudentState extends State<TeacherAssignStudent> {
  DatabaseController db;

  User _user;
  Set<Student> _students;
  String _searchText;


  @override
  void initState() {
    super.initState();
    db = Provider.of<DatabaseController>(context, listen: false);
    _user = Provider.of<User>(context, listen: false);
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
    return StreamBuilder<Set<Student>>(
      stream: db.getStudentsUnassignedTask(_user.id, widget.group.id, widget.task.id),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.length > 0) {
            return Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      Student student = snapshot.data.elementAt(index);
                      if (filtered(student)) {
                        return ListTile(
                          title: Text(student.name),
                          onTap: () {
                            addStudent(student);
                          },
                        );
                      } else {
                        return Container(width: 0.0, height: 0.0,);
                      }
                    })
            );
          } else if (snapshot.hasData) {
            return Expanded(child: Center(child: Text("No students to assign.")));
          } else {
            return Expanded(child: Center(child: CircularProgressIndicator()));
          }
      });
  }

  Future<bool> submitAssignment() {
    if (_students.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("No students selected."),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return Future.value(false);
    } else {
      LoadingDialog loadingDialog = LoadingDialog(
          context: context, text: 'Assigning...');
      loadingDialog.show();

      return db.teacherAssignStudentsToTask(_students, widget.task).then((
          value) {
        loadingDialog.close();
        return true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: BackButtonIcon(),
          onPressed: Navigator.of(context).maybePop,
          tooltip: 'Back',
        ),
        title: const Text('Students To Assign'),
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
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
              buildSuggestions(),
            ],
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: 'Add Students',
        onPressed: () {
          submitAssignment()
              .then((value) {
                if (value) {
                  Navigator.pop(context);
                }
              });
        },
      ),
    );
  }
}