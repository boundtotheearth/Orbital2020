import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';

//View shown when teacher is assigning a task to a student
class TaskStatusTile extends StatefulWidget {
  final TaskWithStatus task;
  final bool isStudent;
  final Function(bool) updateComplete;
  final Function(bool) updateVerify;
  final VoidCallback onFinish;

  TaskStatusTile({
    Key key,
    @required this.task,
    @required this.isStudent,
    this.updateComplete,
    this.updateVerify,
    this.onFinish,
  }) : super(key: key);


  @override
  _StatusTileState createState() => _StatusTileState();
}

class _StatusTileState extends State<TaskStatusTile> {

  @override
  void initState() {

  }

  Widget buildTrailing() {
    if(widget.isStudent) {
      //On Student account
      if(!widget.task.completed) {
        //Not conpleted
        return RaisedButton(
          child: const Text('Complete'),
          onPressed: () => widget.updateComplete(true),
        );
      } else {
        if(widget.task.verified) {
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
      if(!widget.task.completed) {
        //Not conpleted
        return Text('Not completed');
      } else {
        if(widget.task.verified) {
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
        title: Text(widget.task.name),
        subtitle: Text(widget.task.dueDate != null ? ("Due: " + DateFormat('dd/MM/y').format(widget.task.dueDate)) : ""),
        trailing: buildTrailing()
    );
  }
}