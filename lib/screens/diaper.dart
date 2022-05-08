import 'package:baby_tracker/services/api.dart';
import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:baby_tracker/widgets/app_bar.dart';
import 'package:baby_tracker/widgets/numbers_widget.dart';
import 'package:baby_tracker/widgets/profile_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  dynamic heights = [];
  dynamic weights = [];
  bool isLoading = true;

  TextEditingController noteFieldController = TextEditingController();
  TextEditingController diaperTypeController = TextEditingController();
  TextEditingController datePickerController = TextEditingController();

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

  void getHeights() async {
    ApiResponse apiResponse = await Api.get("/babies/${widget.babyId}/sizes");

    if (apiResponse.statusCode == 200) {
      setState(() {
        heights = apiResponse.data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void getWeights() async {
    ApiResponse apiResponse = await Api.get("/babies/${widget.babyId}/weights");

    if (apiResponse.statusCode == 200) {
      setState(() {
        weights = apiResponse.data["data"];
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
    getHeights();
    getWeights();
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

  void addWeight() async {
    var body = <String, dynamic>{
      "weight": noteFieldController.text,
      "created_at": datePickerController.text,
    };

    if (datePickerController.text.isEmpty) {
      body["created_at"] = datePickerController.text;
    }

    ApiResponse apiResponse =
        await Api.post("/babies/${widget.babyId}/weights", body);

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Created Successfully',
          StylishDialogType.SUCCESS);

      getWeights();

      setState(() {
        noteFieldController.text = "";
      });
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }
  }

  void addHeight() async {
    var body = <String, dynamic>{
      "size": noteFieldController.text,
      "created_at": datePickerController.text,
    };

    if (datePickerController.text.isEmpty) {
      body["created_at"] = datePickerController.text;
    }

    ApiResponse apiResponse =
        await Api.post("/babies/${widget.babyId}/sizes", body);

    if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
      showMyDialog(context, 'Success', 'Created Successfully',
          StylishDialogType.SUCCESS);

      getHeights();

      setState(() {
        noteFieldController.text = "";
      });
    } else {
      showMyDialog(
          context, 'Fail', apiResponse.apiError.error, StylishDialogType.ERROR);
    }
  }

  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              noteFieldController.text = "";
              datePickerController.text = "";
              diaperTypeController.text = "";
            });

            switch (currentTabIndex) {
              case 0:
                {
                  _displayAddDiaperDialog(context);
                }
                break;
              case 1:
                {
                  _displayAddWeightDialog(context);
                }
                break;
              case 2:
                {
                  _displayAddHeightDialog(context);
                }
                break;
              default:
                {
                  _displayAddDiaperDialog(context);
                }
                break;
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(CupertinoIcons.profile_circled),
            onPressed: () => {Navigator.pushNamed(context, '/profile')},
            color: Colors.white,
          ),
          title: const Text('Baby Profile'),
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
                                SizedBox(
                                  height: 80,
                                  child: AppBar(
                                    bottom: TabBar(
                                      onTap: (int index) {
                                        setState(() {
                                          currentTabIndex = index;
                                        });
                                      },
                                      tabs: [
                                        Tab(
                                            icon: Icon(
                                                Icons.baby_changing_station),
                                            text: 'Diapers'),
                                        Tab(
                                            icon: Icon(Icons.thermostat),
                                            text: 'Weight'),
                                        Tab(
                                            icon: Icon(Icons.height),
                                            text: 'Height'),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 400,
                                  child: TabBarView(
                                    children: [
                                      diaperInfo(),
                                      weightInfo(),
                                      heightInfo(),
                                    ],
                                  ),
                                )
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
                              child: ProfileWidget(user),
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
      ),
    );
  }

  Column diaperInfo() {
    return Column(
      children: [
        SizedBox(height: 10),
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
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("${diapers[index]['notes']}"),
                    subtitle: Text(
                      "${formatDate(diapers[index]['created_at'])}  ${diapers[index]['type']}",
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Column weightInfo() {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Weight History',
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
                itemCount: weights.length,
                itemBuilder: (_, index) => Card(
                  margin: EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("${weights[index]['weight']}"),
                    subtitle: Text(
                      "${formatDate(weights[index]['created_at'])}",
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Column heightInfo() {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Height History',
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
                itemCount: heights.length,
                itemBuilder: (_, index) => Card(
                  margin: EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("${heights[index]['size']}"),
                    subtitle: Text(
                      "${formatDate(heights[index]['created_at'])}",
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _displayAddDiaperDialog(BuildContext context) async {
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

  Future<void> _displayAddWeightDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Weight'),
            content: Column(
              children: [
                TextField(
                  controller: noteFieldController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      icon: const Icon(CupertinoIcons.book),
                      hintText: "weight"),
                ),
                TextFormField(
                  controller: datePickerController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: 'Created At (optional)',
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

                      datePickerController.text = formatted;
                    }
                  },
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
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    addWeight();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayAddHeightDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Height'),
            content: Column(
              children: [
                TextField(
                  controller: noteFieldController,
                  decoration: InputDecoration(
                      icon: const Icon(CupertinoIcons.book),
                      hintText: "height"),
                ),
                TextFormField(
                  controller: datePickerController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: 'Created At (optional)',
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

                      datePickerController.text = formatted;
                    }
                  },
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
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    addHeight();
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
            "${user!['name'] ?? ''}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
          ),
          const SizedBox(height: 4),
          Text(
            "${user!['gender'] ?? ''}",
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

formatDate(String dateTimeString) {
  final dateTime = DateTime.tryParse(dateTimeString);
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm a');
  return formatter.format(dateTime!);
}
