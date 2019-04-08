import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

  GoogleSignIn _googleSignin = GoogleSignIn(
    scopes: <String>[
      'email', 
      'https://www.googleapis.com/auth/contacts.readonly'
    ]
  );


class HomePage extends StatelessWidget{
  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  void _signOut() async{
    if(_googleSignin != null){
      try{
      await auth.signOut();
      onSignedOut();
    }
    catch (e){
      print(e);
    }
    }
    try{
      await auth.signOut();
      onSignedOut();
    }
    catch (e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Homepage"),
        actions: <Widget>[
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