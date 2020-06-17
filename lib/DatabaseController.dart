import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/ScheduleDetails.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/StudentWithStatus.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';
import 'package:rxdart/rxdart.dart';
import 'DataContainers/TaskStatus.dart';
import 'package:orbital2020/Teacher.dart';

class DatabaseController {
  final db = Firestore.instance;

  void test() async {
    Future<void> a = db.collection('students').getDocuments().then((query) {
      List<DocumentSnapshot> documents = query.documents;
      for(DocumentSnapshot document in documents) {
        db.collection('accountTypes')
            .document(document.documentID)
            .setData({'type': 'student'});
      }
    });
    Future<void> b = db.collection('teachers').getDocuments().then((query) {
      List<DocumentSnapshot> documents = query.documents;
      for(DocumentSnapshot document in documents) {
        db.collection('accountTypes')
            .document(document.documentID)
            .setData({'type': 'teacher'});
      }
    });

    Future.wait([a, b]).then((value) => print("Done"));
  }

  //Get the type of the account, student or teacher
  Future<String> getAccountType({String userId}) {
    return db.collection('accountTypes')
        .document(userId)
        .get()
        .then((value) => value['type'] ?? 'student');
  }

  //Create new student entry in database upon account creation
  Future<void> initialiseNewStudent(Student student)  {
    Future<void> studentFuture = db.collection('students')
            .document(student.id)
            .setData(student.toKeyValuePair());
    Future<void> typeFuture = db.collection('accountTypes')
            .document(student.id)
            .setData({'type': 'student'});
    return Future.wait([studentFuture, typeFuture]);
  }

  //Create new teacher entry in database upon account creation
  Future<void> initialiseNewTeacher(Teacher teacher)  {
    Future<void> teacherFuture = db.collection('teachers')
        .document(teacher.id)
        .setData(teacher.toKeyValuePair());
    Future<void> typeFuture = db.collection('accountTypes')
        .document(teacher.id)
        .setData({'type': 'teacher'});
    return Future.wait([teacherFuture, typeFuture]);
  }

  //Student schedules his task
  Future<void> scheduleTask(String studentId, ScheduleDetails task) {
    return db.collection('students')
        .document(studentId)
        .collection("scheduledTasks")
        .document(task.taskId)
        .setData(task.toKeyValuePair());
  }

  //Student gets all scheduled tasks
//  Stream<List> getScheduledTasksSnapshots(String studentId) {
//    return db.collection("students")
//        .document(studentId)
//        .collection("scheduledTasks")
//        .snapshots()
//        .map((snapshot) => snapshot.documents)
//        .map((documents) => documents.map((document) {
//          return ScheduledTask(
//            id: document.documentID,
//            name: document["name"],
//            scheduledDate: document["scheduledDate"].toDate(),
//            startTime: document["startTime"].toDate(),
//            endTime: document["endTime"].toDate()
//          );
//    })
//    .toList()
//    );
//  }
  
//  Stream<TaskWithStatus> getStudentTask(String studentId, String taskId) {
//    Stream<TaskWithStatus> t = db.collection("students")
//        .document(studentId)
//        .collection("tasks")
//        .document(taskId)
//        .snapshots()
//        .map((document) => TaskWithStatus(
//          id: document.documentID,
//          name: document['name'],
//          dueDate: document['dueDate'].toDate(),
//          createdByName: document['createdByName'],
//          createdById: document['createdById'],
//          completed: document['completed'],
//          verified: document['verified'])
//        );
//    print(t);
//    return t;
//  }

  Stream<Task> getTask(String taskId) {
    return db.collection("tasks")
        .document(taskId)
        .snapshots()
        .map((document) => Task(
          id: document.documentID,
          name: document['name'],
          description: document["description"],
          dueDate: document["dueDate"].toDate(),
          createdById: document["createdById"] ?? "",
          createdByName: document["createdByName"] ?? "",
          tags: document["tags"]?.cast<String>() ?? []
    ));
  }

  Future<String> getTaskName(String taskId) {
    print(taskId);
    return db.collection("tasks")
        .document(taskId)
        .get()
        .then((value) => value.data["name"]);

  }

//  Stream<List<TaskWithStatus>> getTasks(List<TaskStatus> tasks, String orderField) {
//    List<String> taskIds = tasks.map((task) => task.id);
//    return db.collection("tasks")
//        .where("id", whereIn: taskIds)
//        .orderBy(orderField)
//        .snapshots()
//        .map((snapshot) => snapshot.documents.map(
//          (document) => TaskWithStatus(id: document.documentID,
//                          name: document['name'],
//                          description: document["description"],
//                          dueDate: document["dueDate"].toDate(),
//                          createdById: document["createdById"] ?? "",
//                          createdByName: document["createdByName"] ?? "",
//                          tags: document["tags"]?.cast<String>() ?? [],
//                          completed: tasks.firstWhere((task) => task.id == document.documentID).completed,
//                          verified: tasks.firstWhere((task) => task.id == document.documentID).verified)
//          ).toList()
//        );
//  }

  //Get a list of task schedule details from a student
  Stream<List<ScheduleDetails>> getScheduleDetailsSnapshots(String studentId) {
    return db.collection("students")
        .document(studentId)
        .collection("scheduledTasks")
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) => documents.map((document) {
          return ScheduleDetails(
            taskId: document.documentID,
            scheduledDate: document["scheduledDate"].toDate(),
            startTime: document["startTime"].toDate(),
            endTime: document["endTime"].toDate()
          );
    })
    .toList()
    );
  }
  
  //Method to be called with a student creates and assigns themself a task
  Future<void> selfCreateAndAssignTask({Task task, Student student}) {
    return _createTask(task).then((task) =>
        Future.wait([
          _assignTaskToStudent(task, task.id, student.id),
          _assignStudentToTask(student, student.id, task.id)
      ])
    );
  }

  Future<Group> teacherCreateGroup({String teacherId, Group group}) {
    return _createGroup(teacherId, group);
  }

  Future<void> teacherAddStudentsToGroup({String teacherId, Group group, Iterable<Student> students}) {
    return _addStudentsToGroup(teacherId, group, students);
  }

  //Method to be called when a teacher creates a new task
  Future<Task> teacherCreateTask({Task task, Group group}) {
    return _createTask(task).then((newTask) {
      _assignTaskToGroup(newTask, group);
      return newTask;
    });
  }

  //Method to be called when a teacher assigns a task to list of students
  Future<void> teacherAssignTasksToStudent(Iterable<Task> tasks, Student student) {
    WriteBatch batch = db.batch();

    for(Task task in tasks) {
      DocumentReference taskDoc = db.collection('students')
          .document(student.id)
          .collection('tasks')
          .document(task.id);
      DocumentReference stuDoc = db.collection('tasks')
          .document(task.id)
          .collection('students')
          .document(student.id);

      batch.setData(taskDoc, {"completed" : false, "verified" : false});
      batch.setData(stuDoc, student.toKeyValuePair());
    }

    return batch.commit();
  }

  Future<void> teacherAssignStudentsToTask(Iterable<Student> students, Task task) {
    WriteBatch batch = db.batch();

    for(Student student in students) {
      DocumentReference taskDoc = db.collection('students')
          .document(student.id)
          .collection('tasks')
          .document(task.id);
      DocumentReference stuDoc = db.collection('tasks')
          .document(task.id)
          .collection('students')
          .document(student.id);

//      batch.setData(taskDoc, task.addStatus(false, false).toKeyValuePair());
      batch.setData(taskDoc, {"completed" : false, "verified" : false});
      //batch.setData(stuDoc, student.addStatus(false, false).toKeyValuePair());
      batch.setData(stuDoc, student.toKeyValuePair());
    }

    return batch.commit();
  }

  Future<void> createAndAssignTaskToGroup(Task task, String groupId) {
    return Future(null);
  }

  Future<void> updateTaskCompletion(String taskId, String studentId, bool completed) {
//    return Future.wait([
//      _updateStudentCompletion(taskId, studentId, completed),
//      _updateTaskCompletion(taskId, studentId, completed)
//    ]);
    return _updateTaskCompletion(taskId, studentId, completed);
  }

  Future<void> updateTaskVerification(String taskId, String studentId, bool verified) {
//    return Future.wait([
//      _updateStudentVerification(taskId, studentId, verified),
//      _updateTaskVerification(taskId, studentId, verified)
//    ]);
    return  _updateTaskVerification(taskId, studentId, verified);

  }

  //Get a stream of snapshots containing all students and groups in the system.
  Stream<List<Student>> getAllStudentsSnapshots() {
    Stream<List<Student>> students = db.collection('students')
        .snapshots()
        .map((snapshot) {
          List<DocumentSnapshot> documents = snapshot.documents;
          return documents.map((document) {
            Student s = Student(
              id: document.documentID,
              name: document['name'],
            );
            return s;
          })
          .toList();
    });

    return students;
  }

//  Stream<List<String>> getStudentsInGroup(String teacherId, String groupId) {
//    return db.collection("teachers")
//        .document(teacherId)
//        .collection("groups")
//        .document(groupId)
//        .collection("students")
//        .snapshots()
//        .map((snapshot) {
//          List<DocumentSnapshot> documents = snapshot.documents;
//          return documents.map((document) => document.documentID).toList();
//        });
//  }

  Stream<List<Student>> getStudentsNotInGroup(String teacherId, String groupId) {
    return Rx.combineLatest2(getAllStudentsSnapshots(),
        getGroupStudentSnapshots(teacherId: teacherId, groupId: groupId),
            (List<Student> allStudents, Set<Student> currentStudents) {
              allStudents.removeWhere((student) => currentStudents.contains(student));
              return allStudents;
            });
  }

  //Get a stream of snapshots containing all tasks created by a teacher.
  Stream<List<Task>> getTeacherTasksSnapshots({String teacherId}) {
    Stream<List<Task>> groups = db.collection('tasks')
        .where('createdById', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
      List<DocumentSnapshot> documents = snapshot.documents;
      return documents.map((document) {
        Task g = Task(
          id: document.documentID,
          name: document['name'],
          dueDate: document['dueDate'].toDate(),
        );
        return g;
      })
          .toList();
    });

    return groups;
  }

  Stream<Set<TaskStatus>> getStudentTaskDetailsSnapshots({@required String studentId}) {
    Stream<Set<TaskStatus>> tasks = db.collection('students')
        .document(studentId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) {
      return documents.map((document) {
        TaskStatus t = TaskStatus(
            id: document.documentID,
            completed: document['completed'],
            verified: document['verified']);
        return t;
      }).toSet();
    }
    );
    return tasks;
  }

//  Get a stream of snapshots containing tasks assigned to a student with studentId.
//  Each snapshot contains a list of tasks with their corresponding completion status.
//  Stream<Set<TaskWithStatus>> getStudentTaskSnapshots({@required String studentId}) {
//    Stream<Set<TaskWithStatus>> tasks = db.collection('students')
//        .document(studentId)
//        .collection('tasks')
//        .snapshots()
//        .map((snapshot) => snapshot.documents)
//        .map((documents) {
//          return documents.map((document) {
//            TaskWithStatus t = TaskWithStatus(
//                id: document.documentID,
//                name: document['name'],
//                dueDate: document['dueDate'].toDate(),
//                createdByName: document['createdByName'],
//                createdById: document['createdById'],
//                completed: document['completed'],
//                verified: document['verified']);
//            return t;
//          }).toSet();
//        }
//    );
//    return tasks;
//  }

  //Get a stream of snapshots containing students assigned to a task with taskId.
  //Each snapshot contains a list of students with their corresponding completion status.
  Stream<Set<StudentWithStatus>> getTaskStudentSnapshots({@required String taskId}) {
    Stream<Set<StudentWithStatus>> students = db.collection('tasks')
        .document(taskId)
        .collection('students')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) {
      return documents.map((document) {
        StudentWithStatus s = StudentWithStatus(
            id: document.documentID,
            name: document['name'],
            completed: document['completed'],
            verified: document['verified']);
        return s;
      }).toSet();
    }
    );
    return students;
  }

  //Get a stream of snapshots containing tasks that have been assigned to a group.
  //Each snapshot contains a list of tasks, without their completion statuses.
//  Stream<Set<Task>> getGroupTaskSnapshots({String teacherId, String groupId}) {
//    Stream<Set<Task>> tasks = db.collection('teachers')
//        .document(teacherId)
//        .collection('groups')
//        .document(groupId)
//        .collection('tasks')
//        .snapshots()
//        .map((snapshot) => snapshot.documents)
//        .map((documents) =>
//        documents.map((document) {
//          //print(document['tags'].runtimeType);
//          Task t = Task(
//              id: document.documentID,
//              name: document['name'],
//              description: document['description'],
//              dueDate: document['dueDate'].toDate(),
//              tags: document['tags']?.cast<String>() ?? [],
//              createdById: document['createdById'],
//          );
//          return t;
//        }).toSet()
//    );
//    return tasks;
//  }

  Stream<Set<String>> getGroupTaskSnapshots({String teacherId, String groupId}) {
    Stream<Set<String>> tasks = db.collection('teachers')
        .document(teacherId)
        .collection('groups')
        .document(groupId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
        documents.map((document) => document.documentID).toSet()
    );
    return tasks;
  }

  //get group tasks that are unassigned to a particular student
  Stream<Set<String>> getUnassignedTasks(String teacherId, String groupId, String studentId) {
    return Rx.combineLatest2(getGroupTaskSnapshots(teacherId: teacherId, groupId: groupId),
        getStudentTaskDetailsSnapshots(studentId: studentId),
            (Set<String> allTasks, Set<TaskStatus> assignedTasks) {
              allTasks.removeAll(assignedTasks.map((task) => task.id));
              return allTasks;
            });
  }

  //Get a stream of snapshots containing the students in a group.
//  Stream<Set<Student>> getGroupStudentSnapshots({String teacherId, String groupId}) {
//    Stream<Set<Student>> students = db.collection('teachers')
//        .document(teacherId)
//        .collection('groups')
//        .document(groupId)
//        .collection('students')
//        .snapshots()
//        .map((snapshot) => snapshot.documents)
//        .map((documents) =>
//        documents.map((document) {
//          Student s = Student(
//            id: document.documentID,
//            name: document['name'],
//          );
//          return s;
//        }).toSet()
//    );
//    return students;
//  }

  //Obtain a set of students in a group
  Stream<Set<Student>> getGroupStudentSnapshots({String teacherId, String groupId}) {
    return db.collection('teachers')
        .document(teacherId)
        .collection('groups')
        .document(groupId)
        .collection('students')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
        documents.map((document) => Student(id: document.documentID, name: document["name"])).toSet()
        );
  }

  //Get a stream of snapshots containing the groups managed by a teacher.
  //Each snapshot contains a list of groups
  Stream<List<Group>> getTeacherGroupSnapshots({String teacherId}) {
    Stream<List<Group>> groups = db.collection('teachers')
        .document(teacherId)
        .collection('groups')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
        documents.map((document) {
          Group g = Group(
            id: document.documentID,
            name: document['name'],
          );
          return g;
        }).toList()
    );
    return groups;
  }

  // Get a stream of snapshots containing students that the task was assigned to.
  // Each snapshot contains a list of Students and their completion status
//  Stream<void> getTaskCompletionSnapshots(String taskId) {
//    Stream<List<StudentWithStatus>> students = db.collection('tasks')
//        .document(taskId)
//        .collection('students')
//        .snapshots()
//        .map((snapshot) => snapshot.documents)
//        .map((documents) =>
//        documents.map((document) {
//          StudentWithStatus s = StudentWithStatus(
//              id: document.documentID,
//              name: document['name'],
//              completed: document['completed'],
//              verified: document['verified']);
//          return s;
//        }).toList()
//    );
//    return students;
//  }

  //Get list of students that have a certain task
  Stream<List<Student>> getStudentsWithTask(String taskId) {
    return db.collection('tasks')
        .document(taskId)
        .collection('students')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
        documents.map((document) => Student(id: document.documentID, name: document["name"])).toList()
    );
  }

  //get user name from accountTypes
  Stream<String> getUserName(String userId) {
    return db.collection("accountTypes")
        .document(userId)
        .snapshots()
        .map((document) => document["name"]);
  }

  //get students from a group that are unassigned a specific task
  Stream<Set<Student>> getStudentsUnassignedTask(String teacherId, String groupId, String taskId) {
    return Rx.combineLatest2(getGroupStudentSnapshots(teacherId: teacherId, groupId: groupId),
        getStudentsWithTask(taskId),
            (Set<Student> allStudents, List<Student> assginedStudents) {
              allStudents.removeAll(assginedStudents);
              return allStudents;
            });
  }


//  Stream<StudentWithStatus> getStudentNameTaskStatus(String studentId, String taskId) {
//    return Rx.combineLatest2(getStudentTaskStatus(studentId, taskId),
//        getUserName(studentId),
//            (TaskStatus status, String name) {
//            return StudentWithStatus(id: studentId, name: name, completed: status.completed, verified: status.verified);
//        });
//  }



  Stream<TaskStatus> getStudentTaskStatus(String studentId, String taskId) {
    return db.collection('students')
        .document(studentId)
        .collection("tasks")
        .document(taskId)
        .snapshots()
        .map((document) => TaskStatus(
          id: document.documentID,
          completed: document['completed'],
          verified: document['verified'])
    );
  }


  Future<Group> _createGroup(String teacherId, Group group) {
    DocumentReference newGroup = db.collection('teachers')
        .document(teacherId)
        .collection('groups')
        .document();
    group.id = newGroup.documentID;

    WriteBatch batch = db.batch();

    batch.setData(newGroup, group.toKeyValuePair());

    for(Student student in group.students) {
      DocumentReference stuDoc = db.collection('teachers')
          .document(teacherId)
          .collection('groups')
          .document(group.id)
          .collection('students')
          .document(student.id);
      batch.setData(stuDoc, student.toKeyValuePair());
    }

    return batch.commit().then((value) => group);
  }

  Future<void> _addStudentsToGroup(String teacherId, Group group, Iterable<Student> students) {
    WriteBatch batch = db.batch();

    for(Student student in students) {
      DocumentReference stuDoc = db.collection('teachers')
          .document(teacherId)
          .collection('groups')
          .document(group.id)
          .collection('students')
          .document(student.id);
      batch.setData(stuDoc, student.toKeyValuePair());
    }

    return batch.commit();
  }

  //Creates a new task with a random taskID and returns the taskID
  Future<Task> _createTask(Task task) {
    DocumentReference newDoc = db.collection('tasks').document();
    return newDoc.setData(task.toKeyValuePair())
        .then((value) {
          task.id = newDoc.documentID;
          return task;
    });
  }

  Future<void> _assignTaskToGroup(Task task, Group group) {
    return db.collection('teachers')
        .document(task.createdById)
        .collection('groups')
        .document(group.id)
        .collection('tasks')
        .document(task.id)
        .setData({"id" : task.id});
  }

  //Assigns the task with taskID to the student with studentID, duplicating the task data
  Future<void> _assignTaskToStudent(Task task, String taskId, String studentId) {
    //TaskWithStatus taskWithStatus = task.addStatus(false, false);
    return db.collection('students')
        .document(studentId)
        .collection('tasks')
        .document(taskId)
        .setData({"completed" : false, "verified" : false});
        //.setData(taskWithStatus.toKeyValuePair());
  }

  //Assigns the student with studentID to the task with taskId, duplicating the student data
  Future<void> _assignStudentToTask(Student student, String studentId, String taskId) {
    //StudentWithStatus studentWithStatus = student.addStatus(false, false);
    return db.collection('tasks')
        .document(taskId)
        .collection('students')
        .document(studentId)
        .setData(student.toKeyValuePair());
  }

//  Future<void> _updateStudentCompletion(String taskId, String studentId, bool completed) {
//    return db.collection('tasks')
//        .document(taskId)
//        .collection('students')
//        .document(studentId)
//        .updateData({'completed': completed});
//  }

  Future<void> _updateTaskCompletion(String taskId, String studentId, bool completed) {
    return db.collection('students')
        .document(studentId)
        .collection('tasks')
        .document(taskId)
        .updateData({'completed': completed});
  }

//  Future<void> _updateStudentVerification(String taskId, String studentId, bool verified) {
//    return db.collection('tasks')
//        .document(taskId)
//        .collection('students')
//        .document(studentId)
//        .updateData({'verified': verified});
//  }

  Future<void> _updateTaskVerification(String taskId, String studentId, bool verified) {
    return db.collection('students')
        .document(studentId)
        .collection('tasks')
        .document(taskId)
        .updateData({'verified': verified});
  }
}