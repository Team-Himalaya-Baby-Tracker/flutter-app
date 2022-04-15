import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylish_dialog/stylish_dialog.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({Key? key}) : super(key: key);

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  late SharedPreferences sharedPreferences;
  dynamic sentInvitations = [];
  dynamic receivedInvitations = [];
  bool isLoading = true;
  TextEditingController _textFieldController = TextEditingController();

  late String codeDialog;

  void getSentInvitations() async {
    ApiResponse apiResponse = await Api.get("/invitations/sent");

    if (apiResponse.statusCode == 200) {
      setState(() {
        sentInvitations = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void sendInvitation() async {
    ApiResponse apiResponse = await Api.post(
      "/invitations/send",
      <String, String>{
        "email": codeDialog,
      },
    );

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(
          context, 'Success', 'Sent Successfully', StylishDialogType.SUCCESS);
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

  void respondToInvitations(String id, bool isAccepted) async {
    ApiResponse apiResponse = await Api.put(
      "/invitations/$id",
      <String, bool>{
        "accepted": isAccepted,
      },
    );

    if (apiResponse.statusCode == 200) {
      showMyDialog(
          context,
          'Success',
          isAccepted ? 'Accepted Successfully' : 'Rejected Successfully',
          StylishDialogType.SUCCESS);

      getReceivedInvitations();
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }
  }

  void getReceivedInvitations() async {
    ApiResponse apiResponse = await Api.get("/invitations/received");

    if (apiResponse.statusCode == 200) {
      setState(() {
        receivedInvitations = apiResponse.data["data"];
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
    getReceivedInvitations();
    getSentInvitations();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _displayTextInputDialog(context);
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(CupertinoIcons.profile_circled),
            onPressed: () => {Navigator.pushNamed(context, '/profile')},
            color: Colors.white,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.call_received), text: 'Received'),
              Tab(icon: Icon(Icons.call_made), text: 'Sent'),
            ],
          ),
          title: const Text('Invitations'),
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
                    itemCount: receivedInvitations.length,
                    itemBuilder: (_, index) => Card(
                      margin: EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(
                            receivedInvitations![index]!['inviter']!['name']),
                        subtitle: Text(
                          receivedInvitations![index]!['inviter']!['email'],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                respondToInvitations(
                                  receivedInvitations![index]!['id'].toString(),
                                  true,
                                );
                              },
                              icon: Icon(Icons.check),
                              color: Color.fromRGBO(94, 206, 211, 1),
                              hoverColor: Colors.transparent,
                            ),
                            IconButton(
                              onPressed: () {
                                respondToInvitations(
                                  receivedInvitations![index]!['id'].toString(),
                                  false,
                                );
                              },
                              icon: Icon(Icons.close),
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
                    itemCount: sentInvitations.length,
                    itemBuilder: (_, index) => Card(
                      margin: EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title:
                            Text(sentInvitations[index]!['invited']!["name"]),
                        subtitle: Text(
                          sentInvitations[index]!['invited']!['email'],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pending_actions,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Invite Partner'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter Partner Email"),
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
                    sendInvitation();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
