import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

import 'AppDrawer.dart';


class TeacherGroups extends StatefulWidget {

  TeacherGroups({Key key}) : super(key: key);

  @override
  _TeacherGroupsState createState() => _TeacherGroupsState();
}

class _TeacherGroupsState extends State<TeacherGroups> {
  final DatabaseController db = DatabaseController();

  User _user;
  Stream<List<Group>> _groups;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _groups = db.getTeacherGroupSnapshots(teacherId: _user.id);
  }

  Widget _buildGroupList(List<Group> groups) {
    return ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          Group group = groups[index];
          return ListTile(
            leading: Icon(Icons.group),
            title: Text(group.name),
            onTap: () {
              Navigator.of(context).pushNamed('teacher_groupView', arguments: group);
            },
          );
        }
    );
  }

  Future<Null> _refresh() async {
    await Future.microtask(() => setState(() {
      _groups = db.getTeacherGroupSnapshots(teacherId: _user.id);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {

            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Scrollbar(
          child: RefreshIndicator(
              onRefresh: _refresh,
              child: StreamBuilder(
                stream: _groups,
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    if(snapshot.data.length > 0) {
                      return _buildGroupList(snapshot.data);
                    } else {
                      return Text('No groups');
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Add Group',
        onPressed: () {
          Navigator.of(context).pushNamed('teacher_addGroup');
        },
      ),
    );
  }
}