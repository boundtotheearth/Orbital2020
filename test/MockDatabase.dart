//Not currently in use
//import 'package:orbital2020/DatabaseController.dart';
//
//class MockDatabase extends DatabaseController {
//  var database =
//  {
//    'accountTypes':
//    {
//      'CBHrubROTEaYnNwhrxpc3DBwhXx1':
//      {
//        'name': 'Test Student 1',
//        'type': 'student',
//      },
//      '7CYIOUTTHoZkj366BXhVenCs2Wa2':
//      {
//        'name': 'Test Student 2',
//        'type': 'student',
//      },
//      'C3MAYEyLnGeJpUy9vS9m1GwEGZa2':
//      {
//        'name': 'Test Student 3',
//        'type': 'student',
//      },
//      'LbTrn9D90OSSlE1GfhNxQBD5PId2':
//      {
//        'name': 'Test Student 4',
//        'type': 'student',
//      },
//      'P6IYsnpoAZZTdmy2aLBHYHrMf6E2':
//      {
//        'name': 'Test Teacher 1',
//        'type': 'teacher',
//      },
//      'SJoyGmwuGqWZWFZ9fMLefBcIZuH3':
//      {
//        'name': 'Test Teacher 2',
//        'type': 'teacher',
//      }
//    },
//    'tasks':
//    {
//      '3zUERBk2hbJC9xGBgOb9':
//      {
//        'name': 'Test Task 1',
//        'description': 'Test Description 1',
//        'createdByName': 'Test Student 1',
//        'createdById': 'CBHrubROTEaYnNwhrxpc3DBwhXx1',
//        'dueDate': DateTime.now(),
//      },
//      '4qI6jEvRj2vaHYRP9MSs':
//      {
//        'name': 'Test Task 2',
//        'description': 'Test Description 2',
//        'createdByName': 'Test Student 2',
//        'createdById': '7CYIOUTTHoZkj366BXhVenCs2Wa2',
//        'dueDate': DateTime.now(),
//        'tags': ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
//      },
//      '8ih0d2imHTQTVd3tTEgh':
//      {
//        'name': 'Test Task 3',
//        'description': 'Test Description 3',
//        'createdByName': 'Test Student 3',
//        'createdById': 'C3MAYEyLnGeJpUy9vS9m1GwEGZa2',
//        'tags': ['tag1'],
//      },
//      '9uuJmMS55Ro8k1LE0QkC':
//      {
//        'name': 'Test Task 4',
//        'createdByName': 'Test Student 4',
//        'createdById': 'LbTrn9D90OSSlE1GfhNxQBD5PId2',
//        'dueDate': DateTime.now(),
//        'tags': ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
//      },
//      'DK7ZcOOcKlph7CEcf1t5':
//      {
//        'name': 'Test Task 5',
//        'description': 'Test Description 5',
//        'createdByName': 'Test Teacher 1',
//        'createdById': 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2',
//        'dueDate': DateTime.now(),
//        'tags': ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
//      },
//      'DaYQpHZhqXL1q0WfPTff':
//      {
//        'name': 'Test Task 6',
//        'createdByName': 'Test Teacher 1',
//        'createdById': 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2',
//      },
//      'Eq9fPAluCu1HRcNadHzI':
//      {
//        'name': 'Test Task 7',
//        'createdByName': 'Test Teacher 1',
//        'createdById': 'P6IYsnpoAZZTdmy2aLBHYHrMf6E2',
//        'dueDate': DateTime.now(),
//      },
//      'GdCsZlt3WckgptoXUsm8':
//      {
//        'name': 'Test Task 8',
//        'description': 'Test Description 8',
//        'createdByName': 'Test Teacher 2',
//        'createdById': 'SJoyGmwuGqWZWFZ9fMLefBcIZuH3',
//      }
//    },
//    'teachers':
//    {
//      'P6IYsnpoAZZTdmy2aLBHYHrMf6E2':
//      {
//        'name': 'Test Teacher 1',
//        'groups':
//        {
//          'AgRiWVNb2flktExYqpvN':
//          {
//            'name': "Teacher 1 Group 1",
//            'tasks':
//            {
//              'DK7ZcOOcKlph7CEcf1t5': {},
//              'DaYQpHZhqXL1q0WfPTff': {},
//            },
//          },
//          'FrXuSgPaQf25iInKlTjM':
//          {
//            'name': "Teacher 1 Group 2",
//            'students':
//            {
//              'CBHrubROTEaYnNwhrxpc3DBwhXx1': {},
//            },
//            'tasks':
//            {
//              'Eq9fPAluCu1HRcNadHzI': {},
//            },
//          },
//        }
//      },
//      'SJoyGmwuGqWZWFZ9fMLefBcIZuH3':
//      {
//        'name': 'Test Teacher 2',
//        'groups':
//        {
//          'Odo3l9KN7GlwS8enimMH':
//          {
//            'name': "Teacher 2 Group 1",
//            'students':
//            {
//              '7CYIOUTTHoZkj366BXhVenCs2Wa2': {},
//              'C3MAYEyLnGeJpUy9vS9m1GwEGZa2' : {},
//            },
//          },
//          'VJuuT3MBk9bS4IUb2Sej':
//          {
//            'name': "Teacher 2 Group 2",
//          },
//        }
//      }
//    },
//    'students':
//    {
//      'CBHrubROTEaYnNwhrxpc3DBwhXx1':
//      {
//        'name': 'Test Student 1',
//        'scheduledTasks': {},
//        'tasks':
//        {
//          '3zUERBk2hbJC9xGBgOb9':
//          {
//            'completed': false,
//            'verified': false,
//          },
//        },
//      },
//      '7CYIOUTTHoZkj366BXhVenCs2Wa2':
//      {
//        'name': 'Test Student 2',
//        'scheduledTasks': {},
//        'tasks':
//        {
//          '4qI6jEvRj2vaHYRP9MSs':
//          {
//            'completed': true,
//            'verified': true,
//          }
//        },
//      },
//      'C3MAYEyLnGeJpUy9vS9m1GwEGZa2':
//      {
//        'name': 'Test Student 3',
//        'scheduledTasks': {},
//        'tasks':
//        {
//          '8ih0d2imHTQTVd3tTEgh':
//          {
//            'completed': true,
//            'verified': false,
//          }
//        },
//      },
//      'LbTrn9D90OSSlE1GfhNxQBD5PId2':
//      {
//        'name': 'Test Student 4',
//        'scheduledTasks': {},
//        'tasks':
//        {
//          '9uuJmMS55Ro8k1LE0QkC':
//          {
//            'completed': false,
//            'verified': false,
//          }
//        },
//      },
//    },
//  };
//}