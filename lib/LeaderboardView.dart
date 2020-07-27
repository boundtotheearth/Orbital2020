import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/StudentAppDrawer.dart';
import 'package:orbital2020/DataContainers/LeaderboardData.dart';
import 'package:orbital2020/DatabaseController.dart';

class LeaderBoardView extends StatefulWidget {
  LeaderBoardView({Key key}) : super(key: key);

  @override
  _LeaderboardViewState createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderBoardView> {

  final DatabaseController db = DatabaseController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Leaderboard"),
        ),
        drawer: StudentAppDrawer(),
        body: StreamBuilder(
          stream: db.getLeaderboardData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  List<LeaderboardData> leaderboardList = List<LeaderboardData>.from(snapshot.data);
                  leaderboardList.removeWhere((element) => element == null);
                  leaderboardList.sort((a, b) => b.gemTotal.compareTo(a.gemTotal ?? 0));
                  return ListTile(
                    leading: Text((index + 1).toString() + "."),
                    title: Text(leaderboardList[index].name),
                    trailing: Wrap(
                      children: <Widget>[
                        Text(leaderboardList[index].gemTotal.toString()),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )
    );
  }
}