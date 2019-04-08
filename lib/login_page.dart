import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

  GoogleSignIn _googleSignin = GoogleSignIn(
    scopes: <String>[
      'email', 
      'https://www.googleapis.com/auth/contacts.readonly'
    ]
  );

class LoginPage extends StatefulWidget{
  LoginPage({this.auth, this.onSignedIn, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType{
  login,
  register
}

class _LoginPageState extends State<LoginPage>{

  final formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  FormType _formType = FormType.login;

  bool validateAndSave(){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    else{
      return false;
    }
  }

  Future validateAndSubmitGoogle() async{
    if(_formType == FormType.login){
      try{
        await widget.auth.signInWithGoogle(_googleSignin);
        print("tried signing in with google");
      }
      catch (e){
        widget.auth.signOut();
        print (e);
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Google Sign in Failure"),
              content: Text("Something went wrong with signing into the application"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
        );
        widget.onSignedOut();
      }
      widget.onSignedIn();
    }
  }

  Future validateAndSubmit() async {
    if(validateAndSave()){
      bool createButton = false;
      try{
        if(_formType == FormType.login){
          String userID = await widget.auth.signInWithEmailAndPassword(_email, _password);
          print("Signed in: $userID");
        }
        else{
          createButton = true;
          String userID = await widget.auth.createUserWithEmailAndPassword(_email, _password);
          print("Registered user: $userID");
        }
        widget.onSignedIn();
      }
      catch(e){
        print("Error: $e");
        if(createButton){
          showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Email/Password Creation Failure"),
                content: Text("$e"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Close"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
          );
        }
        else{
          if(createButton){
          showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Email/Password Sign in Failure"),
                content: Text("Something went wrong with signing into the application"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Close"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
          );
        }
        }
        
        widget.onSignedOut();
      }
    }
  }

  void moveToRegister(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

    void moveToLogin(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Form"),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildInput() + buildSubmitButtons(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInput(){
    return[
      TextFormField(
        decoration: InputDecoration(labelText: "Email"),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Password"),
        obscureText: true,
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    ];
  }

  List<Widget> buildSubmitButtons(){
    if(_formType == FormType.login){
      return[
        RaisedButton(
          child: Text("Login", style: TextStyle(fontSize: 20.0),),
          onPressed: validateAndSubmit,
        ),
        GoogleSignInButton(
          onPressed: validateAndSubmitGoogle,
          darkMode: true,
        ),
        FlatButton(
          child: Text("Create an Account", style: TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        )
      ];
    }
    else{
      return[
        RaisedButton(
          child: Text("Create an Account", style: TextStyle(fontSize: 20.0),),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text("Have and Account? Login", style: TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        )
      ];
    }
  }
}