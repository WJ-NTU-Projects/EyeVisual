import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

enum DialogType { OK, YES_NO, PROGRESS }

class ADialogAction extends StatelessWidget {
  final AText text;
  final Function() onPressed;
  ADialogAction(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? CupertinoDialogAction(child: text, onPressed: onPressed) : FlatButton(child: text, onPressed: onPressed);
  }
}

class ADialog extends StatelessWidget {
  final DialogType type;
  final String message;
  final String title;
  final Function() onPressed;
  final List<Widget> _actionList = [];
  ADialog(this.type, {this.message, this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    _actionList.clear();
    if (type == DialogType.PROGRESS) return Center(child: AProgressIndicator());
    final Color textColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? ACCENT_COLOR_DARK : ACCENT_COLOR;

    if (type == DialogType.OK) {
      _actionList.add(ADialogAction(AText("OK", style: TextStyle(color: textColor)), () => _onPressed(context)));
    } else if (type == DialogType.YES_NO) {
      _actionList.add(ADialogAction(AText(Platform.isIOS ? "No" : "NO", style: TextStyle(color: textColor)), () => Navigator.of(context).pop()));
      _actionList.add(ADialogAction(AText(Platform.isIOS ? "Yes" : "YES", style: TextStyle(color: textColor)), () => _onPressed(context)));
    }

    Widget dialog;
    AText titleWidget;
    AText contentWidget;

    if (title != null) {
      titleWidget = title != null ? AText(title) : null;
      contentWidget = AText("\n" + message);
    } else {
      contentWidget = AText(message);
    }

    if (Platform.isIOS) {
      dialog = CupertinoAlertDialog(title: titleWidget, content: contentWidget, actions: _actionList);
    } else {
      dialog = AlertDialog(title: titleWidget, content: contentWidget, actions: _actionList, backgroundColor: getColor(context, ColorType.CARD));
    }

    return dialog;
  }

  void _onPressed(BuildContext context) {
    Navigator.of(context).pop();
    if (onPressed != null) onPressed();
  }
}
