import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:baby_tracker/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stylish_dialog/stylish_dialog.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  int _activeStepIndex = 0;
  TextEditingController email = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController code = TextEditingController();

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text('Email'),
          content: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
        Step(
            state:
                _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
            isActive: _activeStepIndex >= 1,
            title: const Text('Set your new password'),
            content: Container(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: code,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Code',
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: newPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New password',
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            )),
      ];

  Future<ApiResponse> forgotPassword() async {
    ApiResponse _apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse('$apiUrl/forgot-password');

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json",
      };

      final response = await http.post(
        url,
        headers: userHeader,
        body: jsonEncode(
          <String, String>{
            "email": email.text,
          },
        ),
      );

      _apiResponse.statusCode = response.statusCode;

      switch (response.statusCode) {
        case 200:
          _apiResponse.data = (json.decode(response.body));
          showMyDialog(context, 'Success', 'Email sent with code',
              StylishDialogType.SUCCESS);
          break;

        case 404:
          showMyDialog(context, 'Fail', 'Wrong email', StylishDialogType.ERROR);
          break;

        default:
          _apiResponse.apiError = ApiError.fromJson(json.decode(response.body));
          String errMsg = _apiResponse.apiError.error;

          showMyDialog(context, 'Fail', errMsg, StylishDialogType.ERROR);

          break;
      }
    } on SocketException {
      _apiResponse.apiError = ApiError(error: "Server error. Please retry");
    }
    return _apiResponse;
  }

  Future<ApiResponse> resetPassword() async {
    ApiResponse _apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse('$apiUrl/reset-password');

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json",
      };

      final response = await http.post(
        url,
        headers: userHeader,
        body: jsonEncode(
          <String, String>{
            "email": email.text,
            "code": code.text,
            "new_password": newPassword.text,
          },
        ),
      );

      _apiResponse.statusCode = response.statusCode;

      switch (response.statusCode) {
        case 200:
          _apiResponse.data = (json.decode(response.body));
          showMyDialog(
              context,
              'Success',
              'Password Changed,\n you can login now with your new password',
              StylishDialogType.SUCCESS);
          break;

        default:
          _apiResponse.apiError = ApiError.fromJson(json.decode(response.body));
          showMyDialog(context, 'Fail', 'Wrong code', StylishDialogType.ERROR);

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
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Column(
        children: [
          Stepper(
            type: StepperType.vertical,
            currentStep: _activeStepIndex,
            steps: stepList(),
            onStepContinue: () async {
              bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(email.text);

              if (_activeStepIndex < (stepList().length - 1)) {
                if (emailValid) {
                  var forgotPasswordResponse = await forgotPassword();

                  if (forgotPasswordResponse.statusCode != 200) {
                    return;
                  }
                }

                if (!emailValid && _activeStepIndex == 0) {
                  return;
                }
                setState(() {
                  _activeStepIndex += 1;
                });
              } else {
                var resetPasswordResponse = await resetPassword();
                if (resetPasswordResponse.statusCode == 200) {
                  Navigator.pushNamed(context, '/login');
                }
              }
            },
            onStepCancel: () {
              if (_activeStepIndex == 0) {
                return;
              }
              setState(() {
                _activeStepIndex -= 1;
              });
            },
            controlsBuilder: (context, ControlsDetails controls) {
              final isLastStep = _activeStepIndex == stepList().length - 1;
              return Container(
                child: Row(
                  children: [
                    if (_activeStepIndex > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controls.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ),
                    if (_activeStepIndex > 0)
                      const SizedBox(
                        width: 10,
                      ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controls.onStepContinue,
                        child: (isLastStep)
                            ? const Text('Change password')
                            : const Text('Next'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
