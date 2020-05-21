//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:orbital2020/DataContainers/Student.dart';
//
//import 'package:orbital2020/DatabaseController.dart';
//import 'package:orbital2020/DataContainers/Task.dart';
//
////View shown when teacher is assigning a task to a student
//class TeacherAssignStudent extends StatefulWidget {
//  final String userId;
//  final Task task;
//
//  TeacherAssignTask({Key key, this.userId, this.task}) : super(key: key);
//
//
//  @override
//  _TeacherAssignStudentState createState() => _TeacherAssignStudentState();
//}
//
//class _TeacherAssignStudentState extends State<TeacherAssignStudent> {
//  final DatabaseController db = DatabaseController();
//
//  Stream<List<Group>> _allGroups;
//  Set<Student> _students;
//  String _searchText;
//
//
//  @override
//  void initState() {
//    super.initState();
//    _allStudents = db.getTeacherTasksSnapshots(teacherId: widget.userId);
//    _students = Set();
//    _searchText = "";
//  }
//
//  List<Widget> buildChips() {
//    List<Widget> taskChips = <Widget>[];
//    for(Task task in _tasks) {
//      taskChips.add(Chip(
//        label: Text(task.name),
//        onDeleted: () {
//          deleteTask(task);
//        },
//      ));
//    }
//    return taskChips;
//  }
//
//  void deleteTask(Task task) {
//    setState(() {
//      _tasks.remove(task);
//    });
//  }
//
//  void addTask(Task task) {
//    setState(() {
//      _tasks.add(task);
//    });
//  }
//
//  Widget buildSuggestions() {
//    return StreamBuilder(
//      stream: _allTasks,
//      builder: (context, snapshot) {
//        if(snapshot.hasData) {
//          List<Task> allTasks = snapshot.data;
//          List<Task> suggestions = allTasks.where((element) =>
//              element.name.startsWith(_searchText)).toList();
//          return ListView.builder(
//              itemCount: suggestions.length,
//              itemBuilder: (context, index) {
//                Task task = suggestions[index];
//                return ListTile(
//                  title: Text(task.name),
//                  onTap: () {
//                    addTask(task);
//                  },
//                );
//              }
//          );
//        } else {
//          return CircularProgressIndicator();
//        }
//      },
//    );
//  }
//
//  Future<void> submitAssignment() {
//    return db.teacherAssignTasksToStudent(_tasks, widget.student);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: const Text('Assign Task'),
//      ),
//      body: SafeArea(
//          child: Column(
//            children: <Widget>[
//              TextField(
//                decoration: const InputDecoration(
//                  labelText: 'Add Students/Groups',
//                ),
//                onChanged: (value) {
//                  setState(() {
//                    _searchText = value;
//                  });
//                },
//              ),
//              Wrap(
//                children: buildChips(),
//              ),
//              Expanded(
//                child: buildSuggestions(),
//              ),
//              RaisedButton(
//                child: const Text('Add New Task'),
//                onPressed: () {
//
//                },
//              )
//            ],
//          )
//      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.check),
//        tooltip: 'Assign Task',
//        onPressed: () {
//          submitAssignment()
//              .then((value) => Navigator.pop(context));
//        },
//      ),
//    );
//  }
//}