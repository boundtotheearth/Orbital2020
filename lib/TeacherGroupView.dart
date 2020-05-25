import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

import 'AppDrawer.dart';

class TeacherGroupView extends StatefulWidget {
  final Group group;

  TeacherGroupView({Key key, @required this.group}) : super(key: key);

  @override
  _TeacherGroupViewState createState() => _TeacherGroupViewState();
}

class _TeacherGroupViewState extends State<TeacherGroupView> with SingleTickerProviderStateMixin{
  final DatabaseController db = DatabaseController();

  User _user;

  Stream<List<Task>> _tasks;
  Stream<Set<Student>> _students;
  TabController _tabController;
  String _searchText;
  bool _searchBarActive;

  @override
  void initState() {
    super.initState();

    _user = Provider.of<User>(context, listen: false);

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _searchText = '';
    _searchBarActive = false;
    _tasks = db.getGroupTaskSnapshots(
        teacherId: _user.id,
        groupId: widget.group.id,
    );
    _students = db.getGroupStudentSnapshots(
        teacherId: _user.id,
        groupId: widget.group.id,
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    List<Task> filteredTasks = tasks.where((task) =>
        task.name.toLowerCase().startsWith(_searchText)).toList();

    return ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          Task task = filteredTasks[index];
          return ListTile(
            title: Text(task.name),
            subtitle: Text("Due: " + DateFormat('dd/MM/y').format(task.dueDate)),
            onTap: () {
              Map<String, dynamic> arguments = {
                'task': task,
                'group': widget.group
              };
              Navigator.of(context).pushNamed('teacher_taskView', arguments: arguments);
            },
          );
        }
    );
  }

  Widget _buildStudentList(Set<Student> students) {
    widget.group.students = students;

    Set<Student> filteredStudents = students.where((student) =>
        student.name.toLowerCase().startsWith(_searchText)).toSet();

    return ListView.builder(
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          Student student = filteredStudents.elementAt(index);
          return ListTile(
            title: Text(student.name),
            onTap: () {
              Navigator.of(context).pushNamed('teacher_studentView', arguments: student);
            },
          );
        }
    );
  }

  Widget _buildTasksTabView() {
    return Scrollbar(
      child: RefreshIndicator(
          onRefresh: _refreshTasks,
          child: StreamBuilder(
            stream: _tasks,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                if(snapshot.data.length > 0) {
                  return _buildTaskList(snapshot.data);
                } else {
                  return Text('No tasks assigned!');
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          )
      ),
    );
  }

  Widget _buildStudentsTabView() {
    return Scrollbar(
      child: RefreshIndicator(
          onRefresh: _refreshStudents,
          child: StreamBuilder(
            stream: _students,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                if(snapshot.data.length > 0) {
                  return _buildStudentList(snapshot.data);
                } else {
                  return Text('No students assigned!');
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          )
      ),
    );
  }

  void _activateSearchBar() {
    setState(() {
      _searchBarActive = true;
    });
  }

  void _deactivateSearchBar() {
    setState(() {
      _searchBarActive = false;
    });
  }

  Widget buildAppBar() {
    if(_searchBarActive) {
      return AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search',
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value.toLowerCase();
            });
          },
          autofocus: true,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.cancel),
            tooltip: 'Cancel',
            onPressed: _deactivateSearchBar,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(child: Text('Tasks'),),
            Tab(child: Text('Students'),),
          ],
        ),
      );
    } else {
      return AppBar(
        title: Text(widget.group.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _activateSearchBar,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(child: Text('Tasks'),),
            Tab(child: Text('Students'),),
          ],
        ),
      );
    }
  }

  Future<Null> _refreshTasks() async {
    await Future.microtask(() => setState(() {
      _tasks = db.getGroupTaskSnapshots(
        teacherId: _user.id,
        groupId: widget.group.id,
      );
    }));
  }

  Future<Null> _refreshStudents() async {
    await Future.microtask(() => setState(() {
      _students = db.getGroupStudentSnapshots(
        teacherId: _user.id,
        groupId: widget.group.id,
      );
    }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildTasksTabView(),
          _buildStudentsTabView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Assign Task',
        onPressed: () {
          if(_tabController.index == 0) {
            Navigator.of(context).pushNamed('teacher_addTask', arguments: widget.group);
          } else if(_tabController.index == 1) {
            Navigator.of(context).pushNamed('teacher_addStudentToGroup', arguments: widget.group);
          }
        },
      ),
    );
  }
}