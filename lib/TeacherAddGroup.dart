import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbital2020/CloudStorageController.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/User.dart';

import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/LoadingDialog.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning a task to a student
class TeacherAddGroup extends StatefulWidget {
  TeacherAddGroup({Key key}) : super(key: key);


  @override
  _TeacherAddGroupState createState() => _TeacherAddGroupState();
}

class _TeacherAddGroupState extends State<TeacherAddGroup> {
  DatabaseController db;
  final CloudStorageController storage = CloudStorageController();
  final _formKey = GlobalKey<FormState>();

  User _user;

  Stream<List<Student>> _allStudents;
  Set<Student> _students;
  String _groupName;
  String _searchText;
  File _groupImage;


  @override
  void initState() {
    super.initState();
    db = Provider.of<DatabaseController>(context, listen: false);
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

  Future<bool> submitGroup() async {
    if(_formKey.currentState.validate()) {
      LoadingDialog loadingDialog = LoadingDialog(context: context, text: 'Adding Group...');
      loadingDialog.show();

      Group newGroup = Group(name: _groupName, students: _students);
      if(_groupImage != null) {
        await storage.uploadGroupImage(image: _groupImage, name: _groupName + DateTime.now().toString()).then((imageUrl) {
          newGroup.imageUrl = imageUrl;
        });
      }
      return db.teacherCreateGroup(teacherId: _user.id, group: newGroup).then((value) {
        loadingDialog.close();
        return true;
      });
    }
    return Future.value(false);
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
        leading: IconButton(
          icon: BackButtonIcon(),
          onPressed: Navigator.of(context).maybePop,
          tooltip: 'Back',
        ),
        title: const Text('New Group'),
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Form(
              key: _formKey,
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
                        child: TextFormField(
                          key: Key('group-name'),
                          decoration: const InputDecoration(
                            labelText: 'Group Name',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _groupName = value;
                            });
                          },
                          validator: RequiredValidator(errorText: "Name cannot be empty!"),
                        ),
                      )
                    ],
                  ),
                  TextFormField(
                    key: Key('add-students'),
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
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: 'Add New Group',
        onPressed: () {
          submitGroup()
              .then((canPop) {
                if(canPop) {
                  Navigator.pop(context);
                }
          });
        },
      )
    );
  }
}