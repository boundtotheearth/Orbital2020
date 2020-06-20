import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbital2020/CloudStorageController.dart';
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
  final CloudStorageController storage = CloudStorageController();

  User _user;

  Stream<List<Student>> _allStudents;
  Set<Student> _students;
  String _groupName;
  String _searchText;
  File _groupImage;


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
              element.name.startsWith(_searchText) && !_students.contains(element)).toList();
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
    return _groupImage != null
        ? storage.uploadGroupImage(image: _groupImage, name: _groupName)
          .then((imageUrl) {
            Group newGroup = Group(name: _groupName, students: _students, imageUrl: imageUrl);
            db.teacherCreateGroup(teacherId: _user.id, group: newGroup);
          })
        : db.teacherCreateGroup(teacherId: _user.id, group: Group(name: _groupName, students: _students));
  }

  Future<File> selectImage() {
    return ImagePicker().getImage(source: ImageSource.gallery)
        .then((pickedFile) {
          File file = File(pickedFile.path);
          setState(() {
            _groupImage = file;
          });
          return file;
    });
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
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: InkWell(
                        onTap: selectImage,
                        child: _groupImage != null ?
                        CircleAvatar(
                          backgroundImage: FileImage(_groupImage),
                          radius: 30,
                        ) :
                        CircleAvatar(
                          child: const Text("G"),
                          radius: 30,
                        )
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _groupName = value;
                        });
                      },
                    ),
                  )
                ],
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
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(Icons.check),
            tooltip: 'Add New Group',
            onPressed: () {
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('Processing Data')));

              submitGroup()
                  .then((value) => Navigator.pop(context));
            },
          );
        },
      )
    );
  }
}