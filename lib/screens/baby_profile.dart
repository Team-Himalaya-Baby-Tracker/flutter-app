import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/widgets/numbers_widget.dart';
import 'package:baby_tracker/widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({Key? key}) : super(key: key);

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  late SharedPreferences sharedPreferences;
  dynamic user;
  bool isLoading = true;

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

  Future<void> refreshBabyProfile() async {
    setState(() {
      isLoading = true;
    });
    getUser();
  }

  initializeState() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initializeState();
    refreshBabyProfile();
  }

  final double circleRadius = 100.0;
  final double circleBorderWidth = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.manage_accounts),
          onPressed: () => {Navigator.pushNamed(context, '/invitations')},
          color: Colors.white,
        ),
        title: const Text('BabyProfile'),
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
              onRefresh: refreshBabyProfile,
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
                          child: Container(
                              //replace this Container with your Card
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 50),
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
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
                      )
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

  Widget buildName(dynamic user) => Column(
        children: [
          Text(
            "${user!['name'] ?? ''}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
          ),
          const SizedBox(height: 4),
          Text(
            "${user!['email'] ?? ''}",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            "${user!['type'] ?? ''}",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            "${user!['birth_date'] ?? ''}",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
}
