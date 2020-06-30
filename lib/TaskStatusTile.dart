import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:provider/provider.dart';

//View shown when teacher is assigning a task to a student
class TaskStatusTile extends StatefulWidget {
  final TaskWithStatus task;
  final bool isStudent;
  final Function(bool) updateComplete;
  final Function(bool) updateVerify;
  final VoidCallback onFinish;
  final VoidCallback onTap;

  TaskStatusTile({
    Key key,
    @required this.task,
    @required this.isStudent,
    this.updateComplete,
    this.updateVerify,
    this.onFinish,
    this.onTap,
  }) : super(key: key);


  @override
  _TaskStatusTileState createState() => _TaskStatusTileState();
}

class _TaskStatusTileState extends State<TaskStatusTile> {
  User _user;


  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
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
            child: const Text('Verifying...'),
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

  List<Chip> getTagChips() {
    return widget.task.tags.map((tag) => Chip(
      label: Text(tag),
    )).toList();
  }

  Widget buildCreatedBy() {
    if(widget.task.createdById == _user.id) {
      return Text("By: Me");
    } else {
      return Text("By: " + widget.task.createdByName ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(widget.task.name),
        subtitle: Column(
          children: [
            widget.task.dueDate != null
              ? Text("Due: " + DateFormat('y-MM-dd').format(widget.task.dueDate))
              : Container(width: 0, height: 0,),
            buildCreatedBy(),
            Wrap(children: widget.isStudent ? getTagChips() : [])
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        trailing: (widget.isStudent || widget.task.createdById == _user.id)
            ? buildTrailing()
            : Text("Task Not Created By You!"),
        isThreeLine: true,
        onTap: widget.onTap,
    );
  }


}