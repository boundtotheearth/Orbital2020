import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital2020/DataContainers/Group.dart';
import 'package:orbital2020/DataContainers/Student.dart';
import 'package:orbital2020/DataContainers/StudentWithStatus.dart';
import 'package:orbital2020/DataContainers/Task.dart';
import 'package:orbital2020/DataContainers/TaskWithStatus.dart';

class DatabaseController {
  final db = Firestore.instance;

  void test() async {
    TaskWithStatus t = TaskWithStatus(id: '1', name: 'test');
  }

  Future<void> initialiseNewStudent(Student student)  {
    return db.collection('students')
            .document(student.id)
            .setData(student.toKeyValuePair());
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

  //Method to be called when a teacher creates a new task
  Future<Task> teacherCreateTask({Task task}) {
    return _createTask(task);
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

      batch.setData(taskDoc, task.addStatus(false, false).toKeyValuePair());
      batch.setData(stuDoc, student.addStatus(false, false).toKeyValuePair());
    }

    return batch.commit();
  }

  Future<void> createAndAssignTaskToGroup(Task task, String groupId) {
    return Future(null);
  }

  Future<void> updateTaskCompletion(String taskId, String studentId, bool completed) {
    return Future.wait([
      _updateStudentCompletion(taskId, studentId, completed),
      _updateTaskCompletion(taskId, studentId, completed)
    ]);
  }

  Future<void> updateTaskVerification(String taskId, String studentId, bool verified) {
    return Future.wait([
      _updateStudentVerification(taskId, studentId, verified),
      _updateTaskVerification(taskId, studentId, verified)
    ]);
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

  //Get a stream of snapshots containing tasks assigned to a student with studentId.
  //Each snapshot contains a list of tasks with their corresponding completion status.
  //If a teacher ID is provided, only tasks belonging to the teacher ID will have their status included
  Stream<List<TaskWithStatus>> getStudentTaskSnapshots({@required String studentId, String teacherId}) {
    Stream<List<TaskWithStatus>> tasks = db.collection('students')
        .document(studentId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) {
          return documents.map((document) {
            TaskWithStatus t = TaskWithStatus(
                id: document.documentID,
                name: document['name'],
                createdByName: document['createdByName'],
                createdById: document['createdById'],
                completed: document['completed'],
                verified: document['verified']);
            return t;
          }).toList();
        }
    );
    return tasks;
  }

  //Get a stream of snapshots containing tasks that have been assigned to a group.
  //Each snapshot contains a list of tasks, without their completion statuses.
  Stream<List<Task>> getGroupTaskSnapshots({String teacherId, String groupId}) {
    Stream<List<Task>> tasks = db.collection('teachers')
        .document(teacherId)
        .collection('groups')
        .document(groupId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
        documents.map((document) {
          Task t = Task(
              id: document.documentID,
              name: document['name'],
              dueDate: document['dueDate'].toDate(),
          );
          print(t);
          return t;
        }).toList()
    );
    return tasks;
  }

  //Get a stream of snapshots containing the students in a group.
  Stream<List<Student>> getGroupStudentSnapshots({String teacherId, String groupId}) {
    Stream<List<Student>> students = db.collection('teachers')
        .document(teacherId)
        .collection('groups')
        .document(groupId)
        .collection('students')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
        documents.map((document) {
          Student s = Student(
            id: document.documentID,
            name: document['name'],
          );
          return s;
        }).toList()
    );
    return students;
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
  Stream<void> getTaskCompletionSnapshots(String taskId) {
    Stream<List<StudentWithStatus>> students = db.collection('tasks')
        .document(taskId)
        .collection('students')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
        documents.map((document) {
          StudentWithStatus s = StudentWithStatus(
              id: document.documentID,
              name: document['name'],
              completed: document['completed'],
              verified: document['verified']);
          return s;
        }).toList()
    );
    return students;
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

  //Creates a new task with a random taskID and returns the taskID
  Future<Task> _createTask(Task task) {
    DocumentReference newDoc = db.collection('tasks').document();
    return newDoc.setData(task.toKeyValuePair())
        .then((value) {
          task.id = newDoc.documentID;
          return task;
    });
  }

  //Assigns the task with taskID to the student with studentID, duplicating the task data
  Future<void> _assignTaskToStudent(Task task, String taskId, String studentId) {
    TaskWithStatus taskWithStatus = task.addStatus(false, false);
    return db.collection('students')
        .document(studentId)
        .collection('tasks')
        .document(taskId)
        .setData(taskWithStatus.toKeyValuePair());
  }

  //Assigns the student with studentID to the task with taskId, duplicating the student data
  Future<void> _assignStudentToTask(Student student, String studentId, String taskId) {
    StudentWithStatus studentWithStatus = student.addStatus(false, false);
    return db.collection('tasks')
        .document(taskId)
        .collection('students')
        .document(studentId)
        .setData(studentWithStatus.toKeyValuePair());
  }

  Future<void> _updateStudentCompletion(String taskId, String studentId, bool completed) {
    return db.collection('tasks')
        .document(taskId)
        .collection('students')
        .document(studentId)
        .updateData({'completed': completed});
  }

  Future<void> _updateTaskCompletion(String taskId, String studentId, bool completed) {
    return db.collection('students')
        .document(studentId)
        .collection('tasks')
        .document(taskId)
        .updateData({'completed': completed});
  }

  Future<void> _updateStudentVerification(String taskId, String studentId, bool verified) {
    return db.collection('tasks')
        .document(taskId)
        .collection('students')
        .document(studentId)
        .updateData({'verified': verified});
  }

  Future<void> _updateTaskVerification(String taskId, String studentId, bool verified) {
    return db.collection('students')
        .document(studentId)
        .collection('tasks')
        .document(taskId)
        .updateData({'verified': verified});
  }
}