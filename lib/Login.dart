import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String _email;
  String _password;

  final formKey = new GlobalKey<FormState>();

  void validateAndLogin() {
    final form = formKey.currentState;
    if (form.validate()) {
      print("Form is valid");
      form.save();
      print("Email: $_email, password: $_password");
    } else {
      print("Form is invalid");
    }
  }

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: "Email cannot be empty"),
    EmailValidator(errorText: "Email format is invalid!"),
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
          Text("Student's Edition",
              style: TextStyle(color: Colors.white, fontSize: 8.0)),
        ]
    );
  }

  Widget _buildForm() {
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
                onPressed: validateAndLogin,
                color: Colors.white,
                child: new Text("LOGIN", style: new TextStyle(
                    color: Colors.green, fontSize: 20.0)),
              )
            ]
        )
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
                _buildForm(),
                SizedBox(
                    height: 30.0
                ),
                Center(
                    child: Text("Don't have an account? Signup here!",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),)
                )
              ],
            )
        )
    );
  }

}