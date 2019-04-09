import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

//GoogleSignIn object detailing the required information for Google Login
  GoogleSignIn _googleSignin = GoogleSignIn(
    scopes: <String>[
      'email', 
      'https://www.googleapis.com/auth/contacts.readonly'
    ]
  );

class LoginPage extends StatefulWidget{
  //Adding objects in the constructer wrapped in {} indicates that they become properties of the class
  //This allows access to the methods detailed in the auth.dart file
  LoginPage({this.auth, this.onSignedIn, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

//Allows for switching between login button setup & logic and register button setup & logic
enum FormType{
  login,
  register
}

class _LoginPageState extends State<LoginPage>{

  final formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  FormType _formType = FormType.login;

//Called from ValidateAndSubmit
//Validates the form and saves its current state
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

//Called from "Sign in with Google" button
//Seperate validAndSubmit function that handles google signins specifically
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

//Called after logging in/creating a new account
//Signs the user into the application
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

//Error Diaglog messages SHOULD be abstracted to new file to make it more modular
//Builds a dialog box with close button detailing the error encountered
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

//Error Diaglog messages SHOULD be abstracted to new file to make it more modular
//Builds a dialog box with close button detailing the error encountered
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

//Called from button press on button "Create an Account"
//Changes the FormType enum to change the button layout and logic to a register page
  void moveToRegister(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

//Called from button press on button "Already have an account"
//Changes the FormType enum to change the button layout and logic to a Login page
    void moveToLogin(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

//Builds the layout of the application screen
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

//This method could be abstracted to a new file for increased modularity
//Builds the email and password text input boxes for the login form.
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

//This method could be abstracted to a new file for increased modularity
//Builds the login/signin with google/create an account/already have an account button & logic
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