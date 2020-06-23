import 'package:mockito/mockito.dart';
import 'package:orbital2020/DatabaseController.dart';

class MockDatabase extends Fake implements DatabaseController {
  var database =
  {
    'accountTypes':
    {
      'CBHrubROTEaYnNwhrxpc3DBwhXx1':
      {
        'name': 'Test Student',
        'type': 'student',
      },
      'P6IYsnpoAZZTdmy2aLBHYHrMf6E2':
      {
        'name': 'Test Teacher',
        'type': 'teacher',
      }
    },
    'tasks':
    {

    },
    'teachers':
    {

    },
    'students':
    {

    },
  };
}