import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylish_dialog/stylish_dialog.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences sharedPreferences;

  bool isLoadingApp = true;

  void checkPreviousSessionAndRedirect() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String? token = sharedPreferences.getString('token');

    if (token != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/profile', (Route<dynamic> route) => false);
    }

    setState(() {
      isLoadingApp = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkPreviousSessionAndRedirect();
  }

  void login() async {
    ApiResponse apiResponse = await Api.post("/login", <String, String>{
      "email": emailController.text,
      "password": passwordController.text,
    });

    if (apiResponse.statusCode == 200) {
      showMyDialog(context, 'Success', 'Logged In', StylishDialogType.SUCCESS);

      sharedPreferences.setString('token', apiResponse.data['token']);

      Navigator.pushNamed(context, '/profile');
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingApp) {
      return const CircularProgressIndicator();
    }
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
                        login();
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
