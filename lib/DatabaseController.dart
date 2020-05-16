import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orbital2020/Task.dart';
import 'package:orbital2020/TaskWithStatus.dart';

class DatabaseController {
  final db = Firestore.instance;

  void test() async {
    TaskWithStatus t = TaskWithStatus(name: 'test');
    print(t.name);
  }
  
  Future<void> createAndAssign(Task task, String studentId) {
    return Future.wait([
      createTask(task),
      assignTaskToStudent(task, studentId)
    ]);
  }

  Future<void> createTask(Task task) {
    return db.collection('tasks')
        .document()
        .setData(task.toKeyValuePair());
  }

  Future<void> assignTaskToStudent(Task task, String studentId) {
    TaskWithStatus taskWithStatus = task.addStatus(false, false);
    return db.collection('students')
        .document(studentId)
        .collection('tasks')
        .document()
        .setData(taskWithStatus.toKeyValuePair());
  }

  Stream<List<TaskWithStatus>> getStudentTaskSnapshots(String studentId) {
    Stream<List<TaskWithStatus>> tasks = db.collection('students')
        .document(studentId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.documents)
        .map((documents) =>
            documents.map((document) {
              TaskWithStatus t = TaskWithStatus(
                  name: document['name'],
                  createdBy: document['createdBy'],
                  completed: document['completed'],
                  verified: document['verified']);
              print("works?" + t.name);
              return t;
            }).toList()
        );
    return tasks;
  }
}