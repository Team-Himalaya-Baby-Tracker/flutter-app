import 'package:baby_tracker/screens/baby_profile.dart';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences sharedPreferences;
  dynamic user;
  dynamic babies = [];
  bool isLoading = true;

  TextEditingController _textFieldController = TextEditingController();

  late String codeDialog;

  void getUser() async {
    ApiResponse apiResponse = await Api.get("/me");

    if (apiResponse.statusCode == 200) {
      setState(() {
        user = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

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

  Future<void> refreshProfile() async {
    setState(() {
      isLoading = true;
    });
    getUser();
    getBabies();
  }

  initializeState() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initializeState();
    refreshProfile();
  }

  final double circleRadius = 100.0;
  final double circleBorderWidth = 8.0;

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

  void deleteBaby(dynamic id) async {
    ApiResponse apiResponse = await Api.delete(
      "/babies/$id",
    );

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Deleted Successfully',
          StylishDialogType.SUCCESS);

      getBabies();
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
          Navigator.pushNamed(context, '/add-baby');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.manage_accounts),
          onPressed: () => {Navigator.pushNamed(context, '/invitations')},
          color: Colors.white,
        ),
        title: const Text('Profile'),
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
              onRefresh: refreshProfile,
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
                                        if (!isLoading && user != null)
                                          NumbersWidget(user),
                                        const SizedBox(height: 24),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 50),
                                          child: ElevatedButton.icon(
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.symmetric(
                                                          vertical: 20.0)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                Color.fromRGBO(94, 206, 211, 1),
                                              ),
                                            ),
                                            label: Text(
                                              'Logout',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            icon: Icon(
                                              Icons.logout,
                                              color: Colors.white,
                                              size: 24.0,
                                            ),
                                            onPressed: () {
                                              sharedPreferences
                                                  .remove('token')
                                                  .then((value) {
                                                if (value) {
                                                  Navigator.pushNamed(
                                                      context, '/login');
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(height: 30),
                              Row(
                                children: [
                                  Text(
                                    'Babies',
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
                                      itemCount: babies.length,
                                      itemBuilder: (_, index) => Card(
                                        margin: EdgeInsets.all(5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                              "${babies![index]!['name']}"),
                                          subtitle: Text(
                                            "${babies![index]!['birth_date']}",
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BabyProfileScreen(
                                                        babyId: babies[index]
                                                                ["id"]
                                                            .toString(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  CupertinoIcons.eye,
                                                ),
                                                color: Color.fromRGBO(
                                                    94, 206, 211, 1),
                                                hoverColor: Colors.transparent,
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  _displayTextInputDialog(
                                                    context,
                                                    babies[index]["id"],
                                                  );
                                                },
                                                icon: Icon(Icons.delete),
                                                color: Colors.red.shade400,
                                                hoverColor: Colors.transparent,
                                              ),
                                            ],
                                          ),
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
                              user,
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

  Future<void> _displayTextInputDialog(BuildContext context, dynamic id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete'),
            content: Text(
              'Are you sure you want to delete this baby?',
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
                    deleteBaby(id);
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
            "${user['email'] ?? ''}",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            "${user['type'] ?? ''}",
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
