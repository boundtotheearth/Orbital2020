import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'AppDrawer.dart';
import 'Sort.dart';

class TeacherGroupView extends StatefulWidget {
  final Group group;

  TeacherGroupView({Key key, @required this.group}) : super(key: key);

  @override
  _TeacherGroupViewState createState() => _TeacherGroupViewState();
}

class _TeacherGroupViewState extends State<TeacherGroupView> with SingleTickerProviderStateMixin{
  final DatabaseController db = DatabaseController();

  User _user;

  Stream<Set<String>> _tasks;
  Stream<Set<Student>> _students;
  TabController _tabController;
  String _searchText;
  bool _searchBarActive;
  Sort _sortTask;
  List<DropdownMenuItem> _options = [
    DropdownMenuItem(child: Text("Name"), value: Sort.name,),
    DropdownMenuItem(child: Text("Due Date"), value: Sort.dueDate,),
  ];

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
    _sortTask = Sort.name;
  }

  bool filtered(String listItem) {
    return listItem.toLowerCase().startsWith(_searchText);
  }

  List<Task> sortAndFilter(List<Task> originalTasks) {
    List<Task> filteredTasks = originalTasks.where((task) => filtered(task.name)).toList();
    switch (_sortTask) {
      case Sort.name:
        filteredTasks.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return filteredTasks;
      case Sort.dueDate:
        filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return filteredTasks;
    }
  }

  Widget _buildTaskList(Set<String> tasks) {
    List<Stream<Task>> streamList = [];
    tasks.forEach((taskId) {
      streamList.add(db.getTask(taskId));
    });

    return StreamBuilder<List<Task>>(
      stream: CombineLatestStream.list(streamList),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Task> filteredTasks = sortAndFilter(snapshot.data);
          return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                Task task = filteredTasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text("Due: " +
                      DateFormat('dd/MM/y').format(task.dueDate)),
                  onTap: () {
                    Map<String, dynamic> arguments = {
                      'task': task,
                      'group': widget.group
                    };
                    Navigator.of(context).pushNamed(
                        'teacher_taskView', arguments: arguments);
                  },
                );
              }
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );


    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          String taskId = tasks.elementAt(index);
          return StreamBuilder<Task>(
            stream: db.getTask(taskId),
            builder: (context, snapshot) {
              if (snapshot.hasData && filtered(snapshot.data.name)) {
                return ListTile(
                  title: Text(snapshot.data.name),
                  subtitle: snapshot.data.dueDate != null ?
                    Text("Due: " + DateFormat('dd/MM/y').format(snapshot.data.dueDate)) :
                    Text(""),
                  onTap: () {
                    Map<String, dynamic> arguments = {
                      'task': snapshot.data,
                      'group': widget.group
                    };
                    Navigator.of(context).pushNamed(
                        'teacher_taskView', arguments: arguments);
                  },
                );
              } else if (snapshot.hasData) {
                return Container(width: 0.0, height: 0.0);
              } else {
                return CircularProgressIndicator();
              }
            }
          );
        }
    );
  }

  Widget _buildStudentList(Set<Student> students) {

    return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          Student student = students.elementAt(index);
          if (filtered(student.name)) {
            return ListTile(
              title: Text(student.name),
              onTap: () {
                Map<String, dynamic> arguments = {
                  'student': student,
                  'group': widget.group
                };
                Navigator.of(context).pushNamed(
                    'teacher_studentView', arguments: arguments);
              },
            );
          } else {
            return Container(width: 0.0, height: 0.0,);
          }
        });
  }

  Widget _buildTasksTabView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButtonFormField(
            items: _options,
            decoration: InputDecoration(
                labelText: "Sort By: "
            ),
            onChanged: (value) => setState(() => _sortTask = value),
            value: _sortTask,
          ),
        ),
        Expanded(
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
          ),
        )
      ]
    );
  }

  Widget _buildStudentsTabView() {
     return StreamBuilder<Set<Student>>(
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
      _searchText = "";
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