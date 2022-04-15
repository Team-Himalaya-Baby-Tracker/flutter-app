import 'dart:convert';
import 'dart:io';

import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/utils.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stylish_dialog/stylish_dialog.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<ApiResponse> login() async {
    ApiResponse _apiResponse = new ApiResponse();

    try {
      Uri url = Uri.parse('$apiUrl/login');

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json",
      };

      final response = await http.post(
        url,
        headers: userHeader,
        body: jsonEncode(
          <String, String>{
            "email": emailController.text,
            "password": passwordController.text,
          },
        ),
      );

      switch (response.statusCode) {
        case 200:
          _apiResponse.data = (json.decode(response.body));
          showMyDialog(
              context, 'Success', 'Logged In', StylishDialogType.SUCCESS);
          break;

        default:
          _apiResponse.apiError = ApiError.fromJson(json.decode(response.body));
          showMyDialog(context, 'Fail', 'Wrong email or password',
              StylishDialogType.ERROR);

          break;
      }
    } on SocketException {
      _apiResponse.apiError = ApiError(error: "Server error. Please retry");
    }
    return _apiResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Image.asset('assets/logo.png'),
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'BABY',
                    style: TextStyle(
                      color: Color.fromRGBO(94, 206, 211, 1),
                      fontWeight: FontWeight.w900,
                      fontSize: 72,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'tracking',
                    style: TextStyle(
                      color: Color.fromRGBO(131, 116, 218, 1),
                      fontWeight: FontWeight.w100,
                      fontSize: 72,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(94, 206, 211, 1)),
                      onPressed: () async {
                        await login();
                      },
                    )),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: <Widget>[
                    const Text('Forgot password?'),
                    TextButton(
                      child: const Text(
                        'Reset password',
                      ),
                      onPressed: () {
                        //signup screen
                        Navigator.pushNamed(context, '/reset-password');
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Row(
                  children: <Widget>[
                    const Text('Not yet registered?'),
                    TextButton(
                      child: const Text(
                        'Register',
                      ),
                      onPressed: () {
                        //signup screen
                        Navigator.pushNamed(context, '/signup');
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
            ),
          )),
    );
  }
}
