import 'package:flutter/material.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/Login.dart';
import 'package:orbital2020/NotificationHandler.dart';
import 'package:provider/provider.dart';
import 'Auth.dart';
import 'AuthProvider.dart';
import 'DataContainers/User.dart';
import 'HomePage.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Auth auth = AuthProvider.of(context).auth;
    return FutureBuilder<User>(
      future: auth.getLoggedInUser(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if(snapshot.hasData) {
          return MultiProvider(
            providers: [
              Provider<User>(
                create: (_) => snapshot.data,
              ),
              Provider<DatabaseController>(
                create: (_) => DatabaseController(),
              )
            ],
            child: MessageHandler(),
          );
        } else if(snapshot.hasError) {
          return LoginPage();
        } else {
          return _buildLoading();
        }
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator()
      )
    );
  }

}