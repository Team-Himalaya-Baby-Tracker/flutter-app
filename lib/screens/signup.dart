import 'dart:convert';
import 'dart:io';

import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:baby_tracker/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stylish_dialog/stylish_dialog.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  DateTime _chosenDateTime = DateTime.parse('19900101');
  String dropdownValue = 'parent';

  Future<ApiResponse> register() async {
    ApiResponse _apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse('$apiUrl/signup');

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json",
      };

      final response = await http.post(
        url,
        headers: userHeader,
        body: jsonEncode(
          <String, String>{
            "name": nameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "type": dropdownValue,
            "birth_date": (_chosenDateTime).toString()
          },
        ),
      );

      switch (response.statusCode) {
        case 200:
          _apiResponse.data = (json.decode(response.body));
          showMyDialog(
              context, 'Success', 'Registered', StylishDialogType.SUCCESS);

          break;

        default:
          _apiResponse.apiError = ApiError.fromJson(json.decode(response.body));
          showMyDialog(
              context, 'Fail', "Couldn't register", StylishDialogType.ERROR);

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
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
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
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(1990, 1, 1),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        _chosenDateTime = newDateTime;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: DropdownButtonFormField<String>(
                    value: dropdownValue,
                    elevation: 16,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Type',
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: [
                      {'name': 'Parent', 'value': 'parent'},
                      {'name': 'Baby Sitter', 'value': 'baby_sitter'}
                    ].map<DropdownMenuItem<String>>((var option) {
                      return DropdownMenuItem<String>(
                        value: option["value"],
                        child: Text(option['name'] ?? ''),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Register'),
                      onPressed: () async {
                        await register();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(94, 206, 211, 1)),
                    )),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: <Widget>[
                    const Text('Already registered?'),
                    TextButton(
                      child: const Text(
                        'Login',
                      ),
                      onPressed: () {
                        //signup screen
                        Navigator.pushNamed(context, '/login');
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
