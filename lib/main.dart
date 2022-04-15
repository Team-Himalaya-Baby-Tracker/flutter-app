import 'package:baby_tracker/screens/login.dart';
import 'package:baby_tracker/screens/reset_password.dart';
import 'package:baby_tracker/screens/signup.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/login': (context) => const Login(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/signup': (context) => const Signup(),
        '/reset-password': (context) => const ResetPasswordPage(),
      },
      theme: ThemeData(
          primaryColor: Color.fromRGBO(94, 206, 211, 1),
          buttonTheme: ButtonThemeData(
            buttonColor: Color.fromRGBO(94, 206, 211, 1),
            textTheme: ButtonTextTheme.primary,
          )),
    );
  }
}
