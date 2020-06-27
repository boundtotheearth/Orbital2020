import 'package:flutter/material.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/Login.dart';
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
            child: HomePage(),
          );
            Provider<User>(
            create: (_) => snapshot.data,
            child: HomePage(),
          );
        } else if(snapshot.hasError) {
          return LoginPage();
        } else {
          return _buildLoading();
        }
      },
    );
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool isLoggedIn = snapshot.hasData;
          return isLoggedIn
            ? Provider<User>(
                create: (_) => snapshot.data,
                child: HomePage()
              )
            : LoginPage();
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