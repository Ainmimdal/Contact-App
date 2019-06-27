import 'package:flutter/material.dart';
import 'screens/HomePage.dart';
import 'SignUpPage.dart';
import 'SignInPage.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firebase Contact",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange
      ),
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        "/SignInPage":(BuildContext context) =>SignInPage(),
        "/SignUpPage":(BuildContext context) =>SignUpPage()
      },
    );
  }
}