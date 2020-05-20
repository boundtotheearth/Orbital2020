import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/AuthProvider.dart';
import 'package:provider/provider.dart';

import 'Auth.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({ Key key }) : super(key: key);
  FirebaseUser _user;

  Future<void> signOut(BuildContext context) async {
    print("Tapped Logout");
    try {
      Auth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      print("Signed out: ${_user.uid}");
    } catch (error) {
      print("$error");
    }
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<FirebaseUser>(context, listen: false);
    return Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text('${_user.displayName}'),
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
            ListTile(
              title: Text('Logout'),
              onTap: () => signOut(context)
            )
          ],
        )
    );
  }

}