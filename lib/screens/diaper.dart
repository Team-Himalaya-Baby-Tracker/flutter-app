import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:baby_tracker/widgets/app_bar.dart';
import 'package:baby_tracker/widgets/numbers_widget.dart';
import 'package:baby_tracker/widgets/profile_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylish_dialog/stylish_dialog.dart';

class DiaperScreen extends StatefulWidget {
  final String babyId;
  const DiaperScreen({Key? key, required this.babyId}) : super(key: key);

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  late SharedPreferences sharedPreferences;
  dynamic user;
  dynamic diapers = [];
  bool isLoading = true;

  TextEditingController noteFieldController = TextEditingController();

  late String codeDialog;

  void getUser() async {
    ApiResponse apiResponse = await Api.get("/babies/${widget.babyId}");

    if (apiResponse.statusCode == 200) {
      setState(() {
        user = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void getDiapers() async {
    ApiResponse apiResponse = await Api.get("/babies/${widget.babyId}/diapers");

    if (apiResponse.statusCode == 200) {
      setState(() {
        diapers = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> refreshDiaper() async {
    setState(() {
      isLoading = true;
    });
    getUser();
    getDiapers();
  }

  initializeState() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initializeState();
    refreshDiaper();
  }

  final double circleRadius = 100.0;
  final double circleBorderWidth = 8.0;

  void addDiaper() async {
    ApiResponse apiResponse = await Api.post(
      "/babies/${widget.babyId}/diapers",
      <String, dynamic>{
        "type": [diaperTypeController.text],
        "notes": noteFieldController.text,
      },
    );

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Created Successfully',
          StylishDialogType.SUCCESS);

      getDiapers();

      setState(() {
        noteFieldController.text = "";
      });
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _displayTextInputDialog(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.profile_circled),
          onPressed: () => {Navigator.pushNamed(context, '/profile')},
          color: Colors.white,
        ),
        title: const Text('Diaper'),
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
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: refreshDiaper,
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: circleRadius / 2.0),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            children: [
                              Container(
                                  height: 180.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade100,
                                          spreadRadius: 1,
                                          blurRadius: 6),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView(
                                      children: [
                                        const SizedBox(height: 45),

                                        if (!isLoading && user != null)
                                          buildName(user),
                                        const SizedBox(height: 24),
                                        // Center(
                                        //   child: buildUpgradeButton(),
                                        // ),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  )),
                              SizedBox(height: 30),
                              Row(
                                children: [
                                  Text(
                                    'Diapers History',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                  height: 340.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade100,
                                          spreadRadius: 1,
                                          blurRadius: 6),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                      itemCount: diapers.length,
                                      itemBuilder: (_, index) => Card(
                                        margin: EdgeInsets.all(5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                              "${diapers[index]['notes']}"),
                                          subtitle: Text(
                                            "${diapers[index]['created_at']}",
                                          ),
                                          // trailing: Row(
                                          //   mainAxisSize: MainAxisSize.min,
                                          //   children: [
                                          //     IconButton(
                                          //       onPressed: () {
                                          //         Navigator.push(
                                          //           context,
                                          //           MaterialPageRoute(
                                          //             builder: (context) =>
                                          //                 DiaperScreen(
                                          //               babyId: diapers[index]
                                          //                       ["type"]
                                          //                   .toString(),
                                          //             ),
                                          //           ),
                                          //         );
                                          //       },
                                          //       icon: Icon(
                                          //         CupertinoIcons.eye,
                                          //       ),
                                          //       color: Color.fromRGBO(
                                          //           94, 206, 211, 1),
                                          //       hoverColor: Colors.transparent,
                                          //     ),
                                          //   ],
                                          // ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: circleRadius,
                        height: circleRadius,
                        decoration: ShapeDecoration(
                            shape: CircleBorder(), color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.all(circleBorderWidth),
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: CircleBorder(),
                            ),
                            child: ProfileWidget(
                              key: const Key("sss"),
                              onClicked: () {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLoading)
              Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: 50.0,
                  width: 50.0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextEditingController diaperTypeController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Diaper'),
            content: Column(
              children: [
                TextField(
                  controller: noteFieldController,
                  decoration: InputDecoration(
                      icon: const Icon(CupertinoIcons.book), hintText: "notes"),
                ),
                DropdownButtonFormField(
                    items: ['wet', 'dry'].map((String category) {
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
                          () => diaperTypeController.text = newValue as String);
                    },
                    //value: _category,
                    decoration: InputDecoration(
                      icon: const Icon(CupertinoIcons.drop),
                      hintText: "Type",
                    )),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.grey.shade400,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Color.fromRGBO(94, 206, 211, 1),
                textColor: Colors.white,
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    addDiaper();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Widget buildName(dynamic user) => Column(
        children: [
          Text(
            "${user['name'] ?? ''}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
          ),
          const SizedBox(height: 4),
          Text(
            "${user['gender'] ?? ''}",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            "${user['birth_date'] ?? ''}",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
}