import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';

class StudentTaskView extends StatefulWidget {
  final TaskWithStatus task;

  StudentTaskView({Key key, @required this.task}) : super(key: key);

  @override
  _StudentTaskViewState createState() => _StudentTaskViewState();
}

class _StudentTaskViewState extends State<StudentTaskView> {
  final DatabaseController db = DatabaseController();
  final _nameFormKey = GlobalKey<FormState>();
  final _mainFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _createdByController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _tagController = TextEditingController();

  User _user;
  bool editable;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    editable = _user.id == widget.task.createdById;
    _nameController.text = widget.task.name;
    _createdByController.text = editable ? "Me" : widget.task.createdByName;
    _descriptionController.text = widget.task.description;
    _dueDateController.text = widget.task.dueDate != null ?
        DateFormat('dd/MM/y').format(widget.task.dueDate) :
        "";
  }

  Future<DateTime> setDueDate(BuildContext context) async {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101)
    ).then((date) {
      setState(() {
        widget.task.dueDate = date;
      });
      return date;
    });
  }

  List<Widget> getTagChips() {
    List<Widget> tagChips = <Widget>[];
    for(String tag in widget.task.tags) {
      tagChips.add(Chip(
        label: Text(tag),
        onDeleted: () {
          deleteTag(tag);
        },
      ));
    }
    return tagChips;
  }

  void deleteTag(String tag) {
    setState(() {
      widget.task.tags.remove(tag);
    });
  }

  void addTag(String tag) {
    setState(() {
      widget.task.tags.add(tag);
    });
  }

  Widget buildCompletedButton() {
    if(!widget.task.completed) {
      //Not conpleted
      return RaisedButton(
        child: const Text('Complete'),
        onPressed: () {
          db.updateTaskCompletion(widget.task.id, _user.id, true)
            .then((value) =>
              setState(() {
                widget.task.completed = true;
              })
          );

        },
      );
    } else {
      if(widget.task.verified) {
        //Completed, verified
        return RaisedButton(
          child: const Text('Claim Reward'),
          onPressed: () {},
        );
      } else {
        //Completed, not verified
        return RaisedButton(
          child: const Text('Waiting for Verification...'),
          onPressed: () {
            db.updateTaskCompletion(widget.task.id, _user.id, true)
              .then((value) =>
              setState(() {
                widget.task.completed = false;
              })
            );
          },
        );
      }
    }
  }

  Future<void> submit() {
    print("submit");
    if (_mainFormKey.currentState.validate() && _nameFormKey.currentState.validate()) {
      _nameFormKey.currentState.save();
      _mainFormKey.currentState.save();

      return db.updateTaskDetails(task: widget.task);
    }
  }

  List<PopupMenuItem> _actionMenuBuilder(BuildContext context) {
    return [
      PopupMenuItem(
        value: 'delete',
        child: Text('Delete', style: TextStyle(color: Colors.red),),
      ),
    ];
  }

  void _onActionMenuSelected(dynamic value) {
    switch(value) {
      case 'delete':
        _onDelete();
        break;
      default:
        print(value.toString() + " Not Implemented");
    }
  }

  Future<void> _onDelete() {
    return db.studentDeleteTask(task: widget.task, studentId: _user.id)
      .then((value) {
        Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Form(
          key: _nameFormKey,
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: UnderlineInputBorder(),
            ),
            style: Theme.of(context).primaryTextTheme.headline6,
            validator: RequiredValidator(errorText: "Name cannot be empty!"),
            onSaved: (value) => widget.task.name = value,
            enabled: editable,
          ),
        ),
        actions: <Widget>[
          editable ? PopupMenuButton(
            itemBuilder: _actionMenuBuilder,
            onSelected: _onActionMenuSelected,
          ) : Container(width: 0, height: 0,)
        ],
      ),
      body: SafeArea(
        child: Form(
            key: _mainFormKey,
            onWillPop: () async {
              return editable ? submit().then((value) => true) : true;
            },
            child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 5),
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Created By',
                      border: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(),
                    ),
                    controller: _createdByController,
                    enabled: false,
                  ),
                  AspectRatio(
                    aspectRatio: 3/2,
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        labelText: 'Description',
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(),
                      ),
                      textAlignVertical: TextAlignVertical.top,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      onSaved: (value) => widget.task.description = value,
                      enabled: editable,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Due',
                              suffixIcon: Icon(Icons.calendar_today),
                              border: InputBorder.none,
                              focusedBorder: UnderlineInputBorder(),
                            ),
                            onTap: () {
                              setDueDate(context).then((value) {
                                if(value != null) {
                                  _dueDateController.text =
                                      DateFormat('dd/MM/y').format(value);
                                }
                              });
                            },
                            controller: _dueDateController,
                            validator: DateValidator('dd/MM/y', errorText: 'Invalid date format!'),
                            enabled: editable,
                          )
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: "Add Tag",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          if(_tagController.text.isNotEmpty) {
                            addTag(_tagController.text);
                            _tagController.text = "";
                          }
                        },
                      ),
                    ),
                    //onFieldSubmitted: (text) => addTag(text),
                    onChanged: (text) {
                      if(text.contains("\n")) {
                        if(!text.startsWith("\n")) {
                          addTag(text.trim());
                        }
                        _tagController.text = "";
                      }
                    },
                    maxLines: 2,
                    minLines: 1,
                    enabled: editable,
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: getTagChips(),
                  ),
                  buildCompletedButton(),
                ]
            ),
          ),
        )
      );
  }
}