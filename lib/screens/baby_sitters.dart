import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylish_dialog/stylish_dialog.dart';

class BabySittersScreen extends StatefulWidget {
  const BabySittersScreen({Key? key}) : super(key: key);

  @override
  State<BabySittersScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<BabySittersScreen> {
  late SharedPreferences sharedPreferences;
  dynamic allBabySitters = [];
  dynamic currentBabySitters = [];
  bool isLoading = true;
  TextEditingController _textFieldController = TextEditingController();

  late String codeDialog;

  void getAllBabySitters() async {
    ApiResponse apiResponse = await Api.get("/baby-sitter");

    if (apiResponse.statusCode == 200) {
      setState(() {
        allBabySitters = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void updateInvitation(
    String id,
  ) async {
    ApiResponse apiResponse = await Api.put(
      "/my-baby-sitter-invitations/${id}",
      <String, String>{
        "expires_at": _chosenDateTime.toString(),
      },
    );

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(
          context, 'Success', 'Sent Successfully', StylishDialogType.SUCCESS);

      getCurrentBabySitters();
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }

    setState(() {
      isLoading = false;
      codeDialog = "";
      _textFieldController.text = "";
    });
  }

  void inviteBabySitter(
    String id,
  ) async {
    String url = "/baby-sitter/invite";

    ApiResponse apiResponse = await Api.post(
      url,
      <String, String>{
        "baby_sitter_id": id,
        "baby_id": dropdownValue,
        "expires_at": _chosenDateTime.toString(),
      },
    );

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Invited Successfully',
          StylishDialogType.SUCCESS);

      getCurrentBabySitters();
      getCurrentBabySitters();
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }
  }

  void getCurrentBabySitters() async {
    String url = "/my-baby-sitter-invitations";

    ApiResponse apiResponse = await Api.get(url);

    if (apiResponse.statusCode == 200) {
      setState(() {
        currentBabySitters = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> refreshInvitations() async {
    setState(() {
      isLoading = true;
    });
    getCurrentBabySitters();
    getAllBabySitters();
    getBabies();
  }

  initializeState() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initializeState();
    refreshInvitations();
  }

  void terminateBabySitter(dynamic id) async {
    ApiResponse apiResponse = await Api.post("/baby-sitter/$id/terminate", {});

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Terminated Successfully',
          StylishDialogType.SUCCESS);

      getCurrentBabySitters();
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(CupertinoIcons.profile_circled),
            onPressed: () => {Navigator.pushNamed(context, '/profile')},
            color: Colors.white,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Current'),
              Tab(icon: Icon(Icons.add_box_rounded), text: 'Hire'),
            ],
          ),
          title: const Text('Baby Sitters'),
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
            child: TabBarView(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ListTileTheme(
                    contentPadding: EdgeInsets.all(15),
                    iconColor: Colors.red,
                    textColor: Colors.black54,
                    tileColor: Colors.white,
                    style: ListTileStyle.list,
                    dense: true,
                    child: ListView.builder(
                      itemCount: currentBabySitters.length,
                      itemBuilder: (_, index) => Card(
                        margin: EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(currentBabySitters![index]![
                              'baby_sitter']!['name']),
                          subtitle: Text(
                            currentBabySitters![index]!['expires_at'],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _displayTerminateDialogue(context,
                                      currentBabySitters![index]!['id']);
                                },
                                icon: Icon(Icons.close),
                                color: Colors.red[400],
                                hoverColor: Colors.transparent,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _chosenDateTime = DateTime.parse(
                                        currentBabySitters![index]![
                                            'expires_at']);
                                  });
                                  _displayInvitationUpdateDialog(
                                      context,
                                      currentBabySitters![index]!['id']
                                          ?.toString());
                                },
                                icon: Icon(Icons.edit),
                                color: Color.fromRGBO(94, 206, 211, 1),
                                hoverColor: Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ListTileTheme(
                    contentPadding: EdgeInsets.all(15),
                    iconColor: Colors.red,
                    textColor: Colors.black54,
                    tileColor: Colors.white,
                    style: ListTileStyle.list,
                    dense: true,
                    child: ListView.builder(
                      itemCount: allBabySitters.length,
                      itemBuilder: (_, index) => Card(
                        margin: EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(allBabySitters![index]!['name']),
                          subtitle: Text(
                            allBabySitters![index]!['birth_date'],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _chosenDateTime = DateTime.now();
                                  });
                                  _displayBabySitterInviteDialogue(
                                    context,
                                    allBabySitters![index]!['id']?.toString(),
                                  );
                                },
                                color: Color.fromRGBO(94, 206, 211, 1),
                                icon: Icon(Icons.person_add),
                                hoverColor: Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  DateTime _chosenDateTime = DateTime.parse(DateTime.now().toString());
  dynamic dropdownValue = null;
  dynamic babies = [];

  void getBabies() async {
    ApiResponse apiResponse = await Api.get("/babies");

    if (apiResponse.statusCode == 200) {
      setState(() {
        babies = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _displayTerminateDialogue(
      BuildContext context, dynamic id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Terminate'),
            content: const Text(
              'Are you sure you want to terminate this baby sitter?',
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
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    terminateBabySitter(id);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayInvitationUpdateDialog(
      BuildContext context, dynamic id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            title: Text('Invite Baby Sitter'),
            content: Column(
              children: [
                Container(
                  height: 200,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 10,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _chosenDateTime,
                      onDateTimeChanged: (DateTime newDateTime) {
                        setState(
                          () {
                            _chosenDateTime = newDateTime;
                          },
                        );
                      },
                    ),
                  ),
                ),
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
                  child: Text('OK'),
                  onPressed: () {
                    setState(() {
                      codeDialog = _textFieldController.text;
                      updateInvitation(id);
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }

  Future<void> _displayBabySitterInviteDialogue(
      BuildContext context, dynamic id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            title: Text('Invite Baby Sitter'),
            content: Column(
              children: [
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
                    items: babies.map<DropdownMenuItem<String>>((var option) {
                      return DropdownMenuItem<String>(
                        value: (option["id"] ?? "").toString(),
                        child: Text(option['name'] ?? ''),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  height: 200,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 10,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _chosenDateTime,
                      onDateTimeChanged: (DateTime newDateTime) {
                        setState(
                          () {
                            _chosenDateTime = newDateTime;
                          },
                        );
                      },
                    ),
                  ),
                ),
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
                  child: Text('OK'),
                  onPressed: () {
                    setState(() {
                      codeDialog = _textFieldController.text;
                      inviteBabySitter(id);
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }
}
