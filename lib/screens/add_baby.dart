import 'dart:convert';
import 'dart:typed_data';
import 'package:baby_tracker/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';
import 'dart:async';

import 'package:stylish_dialog/stylish_dialog.dart';

class AddBabyScreen extends StatefulWidget {
  const AddBabyScreen({Key? key}) : super(key: key);

  @override
  AddBabyScreenState createState() {
    return AddBabyScreenState();
  }
}

// Create a corresponding State class. This class holds data related to the form.
class AddBabyScreenState extends State<AddBabyScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  TextEditingController dateCtl = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  Future getImageFromGallery() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!;
    });
  }

  void addBaby() async {
    if (_image == null ||
        dateCtl.text == '' ||
        nameController.text == '' ||
        genderController.text == '') {
      showMyDialog(
        context,
        'Error',
        'Please fill all the fields',
        StylishDialogType.ERROR,
      );
      return;
    }

    var request = http.MultipartRequest(
        "POST",
        Uri.parse(
          '$apiUrl/babies',
        ));

    request.fields.addAll(<String, String>{
      "birth_date": dateCtl.text,
      "name": nameController.text,
      "gender": genderController.text,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        _image?.path ?? '',
      ),
    );

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${sharedPreferences.getString('token')}"
    };

    request.headers.addAll(userHeader);

    request.send().then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        showMyDialog(context, 'Success', 'Created Successfully',
            StylishDialogType.SUCCESS);
        Navigator.pushNamed(context, '/profile');
      } else {
        showMyDialog(
            context, 'Error', 'Something went wrong', StylishDialogType.ERROR);
      }
    }).catchError((err) {
      showMyDialog(
          context, 'Fail', "Couldn't Add baby", StylishDialogType.ERROR);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.profile_circled),
          onPressed: () => {Navigator.pushNamed(context, '/profile')},
          color: Colors.white,
        ),
        title: const Text('Add Baby'),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        shadowColor: Colors.transparent),
                    onPressed: () {
                      getImageFromGallery();
                    },
                    child: Column(
                      children: [
                        ClipOval(
                          child: Material(
                            color: Colors.transparent,
                            child: _image == null
                                ? Icon(
                                    CupertinoIcons.camera_circle,
                                    color: Colors.white,
                                    size: 50,
                                  )
                                : Image.file(
                                    File(_image?.path ?? ''),
                                    width: 50,
                                    height: 50,
                                  ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(_image == null ? 'Upload' : "Change",
                            style: TextStyle(color: Colors.white)),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.person_outline),
                    labelText: 'Name',
                  ),
                ),
                DropdownButtonFormField(
                    items: ['Male', 'Female', 'Other'].map((String category) {
                      return new DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: <Widget>[
                              Text(category),
                            ],
                          ));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(
                          () => genderController.text = newValue as String);
                    },
                    //value: _category,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.male_outlined),
                      hintText: "Gender",
                    )),
                TextFormField(
                  controller: dateCtl,
                  decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: 'Birth Date',
                  ),
                  onTap: () async {
                    DateTime? date = DateTime(1900);
                    FocusScope.of(context).requestFocus(new FocusNode());

                    date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100));

                    if (date != null) {
                      final DateFormat formatter = DateFormat('yyyy-MM-dd');
                      final String formatted = formatter.format(date);

                      dateCtl.text = formatted;
                    }
                  },
                ),
                Center(
                  child: Container(
                      padding: EdgeInsets.only(left: 0, top: 40.0),
                      child: ElevatedButton(
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: const Color.fromRGBO(94, 206, 211, 1)),
                          onPressed: () {
                            addBaby();
                          })),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
