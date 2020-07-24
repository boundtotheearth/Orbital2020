import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  final String text;
  final BuildContext context;
  BuildContext dialogContext;
  bool canPop = false;
  LoadingDialog({this.context, this.text});

  void show() {
    showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (context) {
        dialogContext = context;
        return WillPopScope(
          onWillPop: () {
            return Future.value(canPop);
          },
          child: SimpleDialog(
            title: ListTile(
              leading: CircularProgressIndicator(),
              title: Text(text),
            ),
            titlePadding: EdgeInsets.all(16),
          ),
        );
      }
    );
  }

  void close() {
    if(dialogContext != null) {
      canPop = true;
      Navigator.of(dialogContext).pop();
    }
  }
}