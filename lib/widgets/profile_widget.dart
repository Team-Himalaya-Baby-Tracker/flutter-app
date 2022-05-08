import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget(this.user);
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildImage(user),
        ],
      ),
    );
  }

  Widget buildImage(dynamic user) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: user != null && user['photo'] != null
            ? buildCircle(
                child: Image.network(
                  user['photo'],
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
                all: 0,
              )
            : const Icon(
                CupertinoIcons.profile_circled,
                color: Colors.black87,
                size: 90,
              ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
