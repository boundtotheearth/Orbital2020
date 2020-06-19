import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:provider/provider.dart';
import 'AppDrawer.dart';


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
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _tagController = TextEditingController();

  User _user;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
    _nameController.text = widget.task.name;
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

  Future<void> submit() {
    print("submit");
    if (_mainFormKey.currentState.validate() && _nameFormKey.currentState.validate()) {
      _nameFormKey.currentState.save();
      _mainFormKey.currentState.save();

      return db.updateTaskDetails(task: widget.task);
    }
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
          ),
        )

      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            return submit().then((value) => true);
          },
          child: Form(
            key: _mainFormKey,
            child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 5),
                children: <Widget>[
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
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: getTagChips(),
                  ),
                ]
            ),
          ),
        )
      ),
    );
  }
}