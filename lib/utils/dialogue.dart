import 'package:flutter/material.dart';
import 'package:stylish_dialog/stylish_dialog.dart';

Future<void> showMyDialog(BuildContext context, String title, String msg,
    StylishDialogType type) async {
  return StylishDialog(
    context: context,
    alertType: type,
    titleText: title,
    contentText: msg,
  ).show();
}
