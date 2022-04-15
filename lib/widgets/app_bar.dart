import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    leading: BackButton(
      onPressed: () => {Navigator.pushNamed(context, '/')},
      color: Colors.black,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    // actions: [
    //   IconButton(
    //     icon: Icon(CupertinoIcons.moon_stars),
    //     onPressed: () {},
    //   ),
    // ],
  );
}
