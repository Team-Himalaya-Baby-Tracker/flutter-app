import 'package:baby_tracker/screens/login.dart';
import 'package:baby_tracker/screens/profile.dart';
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
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/profile': (context) => const ProfileScreen(),
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
