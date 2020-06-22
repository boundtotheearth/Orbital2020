import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:orbital2020/AuthProvider.dart';
import 'package:orbital2020/Root.dart';
import 'package:orbital2020/Teacher.dart';
import 'Auth.dart';
import 'DataContainers/Student.dart';
import 'DatabaseController.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum DisplayType {
  login,
  register
}

enum AccountType {
  student,
  teacher
}

class _LoginPageState extends State<LoginPage> {

  String _name;
  String _email;
  String _password;
  AccountType _accountType = AccountType.student;
  DisplayType _displayType = DisplayType.login;

  final DatabaseController db = DatabaseController();
  final formKey = new GlobalKey<FormState>();
  final passwordKey = new GlobalKey<FormFieldState>();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      print("Form is valid");
      form.save();
      print("Name: $_name, Email: $_email, password: $_password");
      return true;
    } else {
      print("Form is invalid");
      return false;
    }
  }

  Future<void> submit() async {
    if (validateAndSave()) {
      final Auth auth = AuthProvider.of(context).auth;
      if (_displayType == DisplayType.login) {
        String userId = await auth.signInWithEmailPassword(_email, _password);
        if (userId == null) {
          showDialog(
              context: context,
              builder: (_) => _alert("Login failed", "Incorrect credentials. Please try again."),
              barrierDismissible: false
          );
        } else {
          print("Logged in: $userId");
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => RootPage())
          );
        }
      } else {
        String userId = await auth.createAccWithEmailPassword(_name, _email, _password);
        if (userId == null) {
          showDialog(
              context: context,
              builder: (_) => _alert("Register failed", "Please try again."),
              barrierDismissible: false
          );
        } else {
          if(_accountType == AccountType.student) {
            Student newStudent = new Student(id: userId, name: _name);
            db.initialiseNewStudent(newStudent).then((value) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => RootPage())
              );
            });
            print("New Student Account created: $userId");
          } else if(_accountType == AccountType.teacher) {
            Teacher newTeacher = new Teacher(id: userId, name: _name);
            db.initialiseNewTeacher(newTeacher).then((value) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => RootPage())
              );
            });
            print("New Teacher Account created: $userId");
          }
        }
      }
    }
  }

  void redirectToSignup() {
    formKey.currentState.reset();
    setState(() {
      _displayType = DisplayType.register;
    });
  }

  void redirectToLogin() {
    formKey.currentState.reset();
    setState(() {
      _displayType = DisplayType.login;
    });
  }

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: "Email cannot be empty"),
    EmailValidator(errorText: "Email format is invalid!"),
  ]);

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: "Password cannot be empty!"),
    MinLengthValidator(8, errorText: 'Password must be at least 8 characters long!'),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Password must have at least one special character!')
  ]);

  Widget _buildHeader() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.school, size: 150.0),
          Text("Garden of Focus",
            style: TextStyle(color: Colors.white, fontSize: 30.0),),
          //Text("Student's Edition",
              //style: TextStyle(color: Colors.white, fontSize: 8.0)),
        ]
    );
  }

  Widget _loginForm() {
    return Form(
        key: formKey,
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: "Email",
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                validator: emailValidator,
                onSaved: (value) => _email = value,
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: "Password",
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                obscureText: true,
                validator: RequiredValidator(errorText: "Password cannot be empty!"),
                onSaved: (value) => _password = value,
              ),
              new RaisedButton(
                onPressed: submit,
                color: Colors.white,
                child: new Text("LOGIN", style: new TextStyle(
                    color: Colors.green, fontSize: 20.0)),
              )
            ]
        )
    );
  }

  Widget _registerForm() {
    return Form(
        key: formKey,
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(top: 10),
                child: new Text("I am a:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: new RadioListTile(
                      title: new Text("Student", style: TextStyle(fontSize: 16)),
                      value: AccountType.student,
                      groupValue: _accountType,
                      onChanged: (value) {
                        setState(() {
                          _accountType = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: new RadioListTile(
                      title: new Text("Teacher", style: TextStyle(fontSize: 16)),
                      value: AccountType.teacher,
                      groupValue: _accountType,
                      onChanged: (value) {
                        setState(() {
                          _accountType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: "Full Name",
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                validator: RequiredValidator(errorText: "Name cannot be empty!"),
                onSaved: (value) => _name = value,
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: "Email",
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                validator: emailValidator,
                onSaved: (value) => _email = value,
              ),
              new TextFormField(
                key: passwordKey,
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: "Password",
                  helperText: "Password must be at least 8 characters with special character.",
                  helperStyle: TextStyle(fontSize: 9.0),
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                obscureText: true,
                validator: passwordValidator,
                onSaved: (value) => _password = value,
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: "Confirm Password",
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                obscureText: true,
                validator: (value) => MatchValidator(errorText: "Passwords do not match!")
                    .validateMatch(value, passwordKey.currentState.value),
              ),
              new RaisedButton(
                onPressed: submit,
                color: Colors.white,
                child: new Text("SIGN UP", style: new TextStyle(
                    color: Colors.green, fontSize: 20.0)),
              )
            ]
        )
    );
  }

  Widget _redirectText() {
    String question = _displayType == DisplayType.login
        ? "Don't have an account?\n"
        : "Already have an account?\n";
    String action = _displayType == DisplayType.login
        ? "Register here!"
        :  "Login here!";

    return Center(
        child: new RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: question,
              style: TextStyle(color: Colors.white, fontSize: 14.0),
              children: <TextSpan>[
                TextSpan(
                    text: action,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14.0),
                    recognizer: new TapGestureRecognizer()..onTap =
                        _displayType == DisplayType.login
                            ? redirectToSignup
                            : redirectToLogin
                )
              ]
          )
        )
    );

  }

  Widget _alert(String header, String msg) {
    return AlertDialog(
      title: Text(header),
      content: Text(msg),
      actions: <Widget>[
        FlatButton(
          child: Text("Ok"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      elevation: 24.0,

    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        backgroundColor: Colors.lightGreen,
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                _buildHeader(),
                _displayType == DisplayType.login ? _loginForm() : _registerForm(),
                SizedBox(
                    height: 30.0
                ),
                _redirectText()
              ],
            )
        )
    );
  }

}