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
  TextEditingController descriptionController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  DateTime _chosenDateTime = DateTime.parse('19900101');
  String dropdownValue = 'parent';
  dynamic errMsgs;

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
            "description": isDescriptionShown ? descriptionController.text : "",
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

          setState(
            () {
              errMsgs = json.decode(response.body)['errors'];
            },
          );

          break;
      }
    } on SocketException {
      _apiResponse.apiError = ApiError(error: "Server error. Please retry");
    }
    return _apiResponse;
  }

  bool isDescriptionShown = false;

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
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Name',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      errorMaxLines: 1,
                      errorText: errMsgs != null && errMsgs!['name'] != null
                          ? errMsgs!['name']![0]
                          : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Email',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      errorMaxLines: 1,
                      errorText: errMsgs != null && errMsgs!['email'] != null
                          ? errMsgs!['email']![0]
                          : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      errorMaxLines: 1,
                      errorText: errMsgs != null && errMsgs!['password'] != null
                          ? errMsgs!['password']![0]
                          : null,
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(1990, 1, 1),
                    maximumYear: DateTime.now().year - 14,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(
                        () {
                          _chosenDateTime = newDateTime;
                        },
                      );
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

                        if (newValue == 'baby_sitter') {
                          isDescriptionShown = true;
                        } else {
                          isDescriptionShown = false;
                        }
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
                  height: 10,
                ),
                isDescriptionShown
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Description",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            errorMaxLines: 1,
                            errorText: errMsgs != null &&
                                    errMsgs!['description'] != null
                                ? errMsgs!['description']![0]
                                : null,
                          ),
                        ),
                      )
                    : Container(),
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
