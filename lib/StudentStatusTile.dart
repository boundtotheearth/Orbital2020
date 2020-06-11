import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2020/DataContainers/StudentWithStatus.dart';

//View shown when teacher is assigning a task to a student
class StudentStatusTile extends StatefulWidget {
  final StudentWithStatus student;
  final bool isStudent;
  final Function(bool) updateComplete;
  final Function(bool) updateVerify;
  final VoidCallback onFinish;

  StudentStatusTile({
    Key key,
    @required this.student,
    @required this.isStudent,
    this.updateComplete,
    this.updateVerify,
    this.onFinish,
  }) : super(key: key);


  @override
  _StudentStatusTileState createState() => _StudentStatusTileState();
}

class _StudentStatusTileState extends State<StudentStatusTile> {
  Widget buildTrailing() {
    if(widget.isStudent) {
      //On Student account
      if(!widget.student.completed) {
        //Not conpleted
        return RaisedButton(
          child: const Text('Complete'),
          onPressed: () => widget.updateComplete(true),
        );
      } else {
        if(widget.student.verified) {
          //Completed, verified
          return RaisedButton(
            child: const Text('Claim Reward'),
            onPressed: () => widget.onFinish,
          );
        } else {
          //Completed, not verified
          return RaisedButton(
            child: const Text('Waiting for Verification...'),
            onPressed: () => widget.updateComplete(false),
          );
        }
      }
    } else {
      //On Teacher Account
      if(!widget.student.completed) {
        //Not conpleted
        return Text('Not completed');
      } else {
        if(widget.student.verified) {
          //Completed, verified
          return RaisedButton(
            child: const Text('Undo Verify'),
            onPressed: () => widget.updateVerify(false),
          );
        } else {
          //Completed, not verified
          return Wrap(
            children: <Widget>[
              RaisedButton(
                child: const Text('Redo'),
                onPressed: () => widget.updateComplete(false),
              ),
              RaisedButton(
                child: const Text('Verify'),
                onPressed: () => widget.updateVerify(true),
              ),
            ],
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(widget.student.name),
        trailing: buildTrailing()
    );
  }
}