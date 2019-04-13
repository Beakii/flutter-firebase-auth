import 'package:fire_login/auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

class HomePage extends StatelessWidget{

  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

    void _signOut() async{
    try{
      await auth.signOut();
      onSignedOut();
    }
    catch (e){
      print(e);
    }
  }

//Builds homepage "welcome" text and Logout button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Homepage"),
        actions: <Widget>[
          //OnPressed calls the _signOut method which will sign the user out of firebase.
          FlatButton(
            child: Text("Logout", style: TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        child: Center(
          child: Text("Welcome", style: TextStyle(fontSize: 32.0)),
        ),
      ),
    );
  }
}