import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/CloudStorageController.dart';
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
  final CloudStorageController storage = CloudStorageController();

  User _user;
  Stream<List<Group>> _groups;
  String _searchText;
  bool _searchBarActive;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _groups = db.getTeacherGroupSnapshots(teacherId: _user.id);
    _searchText = "";
    _searchBarActive = false;
  }

  Widget _buildGroupList(List<Group> groups) {
    List<Group> filteredGroups = groups.where((group) =>
        group.name.toLowerCase().startsWith(_searchText)).toList();
    return ListView.builder(
        itemCount: filteredGroups.length,
        itemBuilder: (context, index) {
          Group group = filteredGroups[index];
          return ListTile(
            leading: group.imageUrl != null ?
              CircleAvatar(
                backgroundImage: NetworkImage(group.imageUrl),
                radius: 25,
              ) :
              CircleAvatar(
                child: const Text("G"),
                radius: 25,
              ),
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
      );
    } else {
      return AppBar(
        title: const Text('Groups'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _activateSearchBar,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
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