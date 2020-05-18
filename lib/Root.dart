import 'package:flutter/material.dart';
import 'package:orbital2020/Login.dart';
import 'package:orbital2020/StudentMain.dart';
import 'Auth.dart';
import 'AuthProvider.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Auth auth = AuthProvider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool isLoggedIn = snapshot.hasData;
          return isLoggedIn ? StudentMain(userId: snapshot.data,) : LoginPage();
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