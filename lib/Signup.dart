import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';


class SignupPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _SignupPageState();

}

class _SignupPageState extends State<SignupPage> {

  final formKey = new GlobalKey<FormState>();
  final passwordKey = new GlobalKey<FormFieldState>();
  String _name;
  String _email;
  String _password;

  void validateSaveForm() {
    final form = formKey.currentState;
    if (form.validate()) {
      print("Form is valid");
      form.save();
    } else {
      print("Form is invalid");
    }
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
                onPressed: validateSaveForm,
                color: Colors.white,
                child: new Text("SIGN UP", style: new TextStyle(
                    color: Colors.green, fontSize: 20.0)),
              )
            ]
        )
    );
  }


  @override
  Widget build(BuildContext context) {
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
                  child: Text("Already have an account? Login here!",
                    style: TextStyle(color: Colors.white, fontSize: 12.0),)
                )
              ],
            )
        )
    );
  }


}