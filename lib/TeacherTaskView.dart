import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskStatus.dart';
import 'package:orbital2020/DataContainers/User.dart';
import 'package:orbital2020/DatabaseController.dart';
import 'package:orbital2020/StudentStatusTile.dart';
import 'package:orbital2020/TaskProgressIndicator.dart';
import 'package:provider/provider.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:rxdart/rxdart.dart';
import 'AppDrawer.dart';


class TeacherTaskView extends StatefulWidget {
  final Task task;
  final Group group;

  TeacherTaskView({Key key, @required this.task, @required this.group}) : super(key: key);

  @override
  _TeacherTaskViewState createState() => _TeacherTaskViewState();
}

class _TeacherTaskViewState extends State<TeacherTaskView> with SingleTickerProviderStateMixin{
  final DatabaseController db = DatabaseController();
  final _nameFormKey = GlobalKey<FormState>();
  final _mainFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _tagController = TextEditingController();

  Stream<List<Student>> _students;
  User _user;
  String _searchText;
  bool _searchBarActive;
  TabController _tabController;
  bool _canSearch;

  @override
  void initState() {
    super.initState();
    _students = db.getStudentsWithTask(widget.task.id);
    _user = Provider.of<User>(context, listen: false);
    _searchText = '';
    _searchBarActive = false;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(onTabChange);
    _canSearch = false;
    _nameController.text = widget.task.name;
    _descriptionController.text = widget.task.description;
    _dueDateController.text = widget.task.dueDate != null ?
    DateFormat('dd/MM/y').format(widget.task.dueDate) :
    "";
  }

  bool filtered(String studentName) {
    return studentName.toLowerCase().startsWith(_searchText);
  }

  Widget _buildStudentList(List<Student> students) {
    return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          Student student = students[index];
          //get task status stream for that student
          return StreamBuilder<TaskStatus>(
            stream: db.getStudentTaskStatus(student.id, widget.task.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && filtered(student.name)) {
                return StudentStatusTile(
                student: student.addStatus(snapshot.data.completed, snapshot.data.verified),
                isStudent: _user.accountType == 'student',
                updateComplete: (value) {
                  db.updateTaskCompletion(widget.task.id, student.id, value);
                },
                updateVerify: (value) {
                  db.updateTaskVerification(widget.task.id, student.id, value);
                },
                onFinish: () {},
                );
              } else if (snapshot.hasData) {
                return Container(width: 0.0, height: 0.0);
              } else {
                return CircularProgressIndicator();
              }
            });

        });
  }

  Future<Null> _refresh() async {
    await Future.microtask(() => setState(() {
      _students = db.getStudentsWithTask(widget.task.id);
    }));
  }

  List<PopupMenuItem> _actionMenuBuilder(BuildContext context) {
    return [
      PopupMenuItem(
        value: 'all_submitted',
        child: Text('All Submitted'),
      ),
      PopupMenuItem(
        value: 'clear_all',
        child: Text('Clear All'),
      ),
      PopupMenuItem(
        value: 'archive',
        child: Text('Archive'),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Text('Delete', style: TextStyle(color: Colors.red),),
      )
    ];
  }

  void _onActionMenuSelected(dynamic value) {
    switch(value) {
      case 'all_submitted':
        _onAllSubmitted();
        break;
      case 'clear_all':
        _onClearAll();
        break;
      case 'archive':
        _onArchive();
        break;
      case 'delete':
        _onDelete();
        break;
      default:
        print(value.toString() + " Not Implemented");
    }
  }

  Future<void> _onAllSubmitted() {
    return Future(null);
  }

  Future<void> _onArchive() {
    return Future(null);
  }

  Future<void> _onClearAll() {
    return Future(null);
  }

  Future<void> _onDelete() {
    return db.teacherDeleteTask(task: widget.task, group: widget.group)
        .then((value) => Navigator.of(context).pop());
  }

  void _activateSearchBar() {
    setState(() {
      _searchBarActive = true;
    });
  }

  void _deactivateSearchBar() {
    setState(() {
      _searchBarActive = false;
    });
  }

  Widget buildAppBar() {
    if (_searchBarActive) {
      return AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search',
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value.toLowerCase();
            });
          },
          autofocus: true,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.cancel),
            tooltip: 'Cancel',
            onPressed: _deactivateSearchBar,
          )
        ],
      );
    } else {
      return AppBar(
        //title: Text(widget.task.name),
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
        ),
        actions: <Widget>[
          _canSearch ? IconButton(
            icon: Icon(Icons.search),
            onPressed: _activateSearchBar,
          ) : Container(width: 0, height: 0,),
          PopupMenuButton(
            itemBuilder: _actionMenuBuilder,
            onSelected: _onActionMenuSelected,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(child: Text("Details"),),
            Tab(child: Text("Assigned"),),
          ],
        ),
      );
    }
  }

  void onTabChange() {
    setState(() {
      _canSearch = _tabController.index == 0 ? false : true;
      if(_tabController.index == 0) {
        submit();
      }
    });
  }

  Widget buildAssignedTab() {
    return SafeArea(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: _students,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  List<Stream<TaskStatus>> streamList = [];
                  snapshot.data.forEach((Student student) {
                    streamList.add(db.getStudentTaskStatus(student.id, widget.task.id));
                  });

                  return StreamBuilder<List<TaskStatus>>(
                      stream: CombineLatestStream.list(streamList),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int total = snapshot.data.length;
                          int completed = snapshot.data.where((task) => task.completed).length;
                          return AspectRatio(
                            aspectRatio: 3 / 2,
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: CustomPaint(
                                  foregroundPainter: TaskProgressIndicator(total > 0 ?
                                  completed / total
                                      : 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("$completed/$total",
                                        style: TextStyle(fontSize: 28,
                                            fontWeight: FontWeight.bold),),
                                      Text("Completed",
                                        style: TextStyle(fontSize: 20),)
                                    ],
                                  ),
                                )
                            ),
                          );
                        } else {
                          return ListTile(
                            title: CircularProgressIndicator(),
                          );
                        }
                      }
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Expanded(
              child: Scrollbar(
                child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: StreamBuilder(
                      stream: _students,
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          if(snapshot.data.length > 0) {
                            return _buildStudentList(snapshot.data);
                          } else {
                            return Text('No students assigned!');
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    )
                ),
              ),
            ),
          ],
        )
    );
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
    if (_mainFormKey.currentState.validate() && _nameFormKey.currentState.validate()) {
      _nameFormKey.currentState.save();
      _mainFormKey.currentState.save();
      return db.updateTaskDetails(task: widget.task);
    }
  }

  Widget buildDetailsTab() {
    return SafeArea(
        child: Form(
            key: _mainFormKey,
            onWillPop: () => submit().then((value) => true),
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
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: AppDrawer(),
      body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            buildDetailsTab(),
            buildAssignedTab(),
          ],
        )
      );
  }
}