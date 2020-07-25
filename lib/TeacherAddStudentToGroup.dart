import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/LoadingDialog.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning a task to a student
class TeacherAddStudentToGroup extends StatefulWidget {
  final Group group;

  TeacherAddStudentToGroup({Key key, @required this.group}) : super(key: key);

  @override
  _TeacherAddStudentToGroupState createState() => _TeacherAddStudentToGroupState();
}

class _TeacherAddStudentToGroupState extends State<TeacherAddStudentToGroup> {
  DatabaseController db;

  User _user;
  Set<Student> _studentsToAdd;
  String _searchText;


  @override
  void initState() {
    super.initState();
    db = Provider.of<DatabaseController>(context, listen: false);
    _user = Provider.of<User>(context, listen: false);
    _studentsToAdd = Set();
    _searchText = "";
  }

  List<Widget> buildChips() {
    List<Widget> studentChips = <Widget>[];
    for(Student student in _studentsToAdd) {
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
      _studentsToAdd.remove(student);
    });
  }

  void addStudent(Student student) {
    setState(() {
      _studentsToAdd.add(student);
    });
  }

  Widget buildSuggestions() {
    return StreamBuilder(
      stream: db.getStudentsNotInGroup(_user.id, widget.group.id),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          List<Student> suggestions = snapshot.data.where((element) =>
          element.name.startsWith(_searchText) && !_studentsToAdd.contains(element)).toList();
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
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<bool> submitAdd() {
    if(_studentsToAdd.isNotEmpty) {
      LoadingDialog loadingDialog = LoadingDialog(context: context, text: 'Adding Students...');
      loadingDialog.show();
      return db.teacherAddStudentsToGroup(teacherId: _user.id,
          group: widget.group,
          students: _studentsToAdd).then((value) {
            loadingDialog.close();
            return true;});
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
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
        title: const Text('Add Students To Group'),
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
                Expanded(
                  child: buildSuggestions(),
                ),
              ],
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: 'Add Students',
        onPressed: () {
          submitAdd()
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