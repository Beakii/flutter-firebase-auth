import 'package:flutter/material.dart';
import 'auth.dart';
import 'root_page.dart';

main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RootPage(auth: Auth(),)
    );
  }
}