import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Username'),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                print('Tapped Home');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Add task'),
              onTap: () {
                print('Tapped Add Task');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Groups'),
              onTap: () {
                print('Tapped Groups');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                print('Tapped Settings');
                Navigator.pop(context);
              },
            ),
          ],
        )
    );
  }

}