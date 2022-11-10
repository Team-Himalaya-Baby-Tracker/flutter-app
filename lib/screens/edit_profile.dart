import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';

import 'package:baby_tracker/utils/dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:stylish_dialog/stylish_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  EditProfileScreenState createState() {
    return EditProfileScreenState();
  }
}

// Create a corresponding State class. This class holds data related to the form.
class EditProfileScreenState extends State<EditProfileScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  final _form2Key = GlobalKey<FormState>();

  dynamic user;

  bool isLoading = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  void updateProfile() async {
    ApiResponse apiResponse = await Api.put(
      "/me",
      <String, String>{
        "name": nameController.text,
        "description": descriptionController.text,
      },
    );

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Updated Successfully',
          StylishDialogType.SUCCESS);
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }

    setState(() {
      isLoading = true;
    });

    getUser();
  }

  void updatePassword() async {
    ApiResponse apiResponse = await Api.put(
      "/me",
      <String, String>{
        "password": newPasswordController.text,
        "current_password": currentPasswordController.text,
      },
    );

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Changed Successfully',
          StylishDialogType.SUCCESS);
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }

    setState(() {
      isLoading = true;
    });

    getUser();
  }

  void getUser() async {
    ApiResponse apiResponse = await Api.get("/me");

    if (apiResponse.statusCode == 200) {
      setState(() {
        user = apiResponse.data["data"];
        nameController.text = user["name"];
        descriptionController.text = user["description"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.profile_circled),
          onPressed: () => {Navigator.pushNamed(context, '/profile')},
          color: Colors.white,
        ),
        title: const Text('Update Profile'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(96, 198, 211, 1),
              Color.fromRGBO(127, 114, 217, 1),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 20),
                      Text(
                        "Update Info",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.person_outline,
                            color: Colors.black54,
                          ),
                          labelText: 'Name',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.black12,
                            ),
                          ),
                          focusColor: Colors.black12,
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.description,
                            color: Colors.black54,
                          ),
                          labelText: 'Description',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.black12,
                            ),
                          ),
                          focusColor: Colors.black12,
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                            padding: EdgeInsets.only(left: 0, top: 40.0),
                            child: ElevatedButton(
                              child: Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromRGBO(94, 206, 211, 1)),
                              onPressed: '_image' != null
                                  ? () {
                                      updateProfile();
                                    }
                                  : () {},
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              child: (Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Divider(color: Colors.white, thickness: 2),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )
                ],
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form2Key,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Change Password",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.password,
                            color: Colors.black54,
                          ),
                          labelText: 'Current Password',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.black12,
                            ),
                          ),
                          focusColor: Colors.black12,
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.password,
                            color: Colors.black54,
                          ),
                          labelText: 'New Password',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.black12,
                            ),
                          ),
                          focusColor: Colors.black12,
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                            padding: EdgeInsets.only(left: 0, top: 40.0),
                            child: ElevatedButton(
                                child: Text(
                                  'Change',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: Color.fromRGBO(94, 206, 211, 1)),
                                onPressed: () {
                                  updatePassword();
                                })),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
