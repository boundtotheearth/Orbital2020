import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:orbital2020/DatabaseController.dart';

class MockDatabaseController extends DatabaseController{
  MockDatabaseController() {
    db = MockFirestoreInstance();
  }

  String showDB() {
    MockFirestoreInstance mockDB = db as MockFirestoreInstance;
    return mockDB.dump();
  }
}