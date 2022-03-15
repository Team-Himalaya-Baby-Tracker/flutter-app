import 'dart:convert';
import 'dart:io';

import 'package:baby_tracker/utils/dialogue.dart';
import 'package:baby_tracker/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
          _apiResponse.Data = (json.decode(response.body));
          showMyDialog(context, 'Success', 'Registered');

          break;

        default:
          _apiResponse.ApiError = ApiError.fromJson(json.decode(response.body));
          showMyDialog(context, 'Fail', "Couldn't register");

          break;
      }
    } on SocketException {
      _apiResponse.ApiError = ApiError(error: "Server error. Please retry");
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
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Baby Tracker',
                      style: TextStyle(
                          color: Color.fromARGB(255, 148, 19, 90),
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 20),
                    )),
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

class ApiResponse {
  // _data will hold any response converted into
  // its own object. For example user.
  late Object _data;
  // _apiError will hold the error object
  late Object _apiError;

  Object get Data => _data;
  set Data(Object data) => _data = data;

  Object get ApiError => _apiError as Object;
  set ApiError(Object error) => _apiError = error;
}

class ApiError {
  late String _error;

  ApiError({required String error}) {
    _error = error;
  }

  String get error => _error;
  set error(String error) => _error = error;

  ApiError.fromJson(Map<String, dynamic> json) {
    _error = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = _error;
    return data;
  }
}
