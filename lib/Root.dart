import 'package:flutter/material.dart';
import 'package:orbital2020/Login.dart';
import 'package:orbital2020/StudentMain.dart';
import 'package:provider/provider.dart';
import 'Auth.dart';
import 'AuthProvider.dart';
import 'HomePage.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Auth auth = AuthProvider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool isLoggedIn = snapshot.hasData;
          return isLoggedIn
            ? Provider<String>(
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