import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class ADivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 0, thickness: 0.8, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? DIVIDER_COLOR_DARK : DIVIDER_COLOR);
  }
}

class APositioned extends StatelessWidget {
  final Alignment align;
  final Widget child;
  APositioned(this.align, this.child);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: Align(alignment: align, child: child));
  }
}

class AProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator();
  }
}

class AWaitingUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: AProgressIndicator());
  }
}

class AnErrorUI extends StatelessWidget {
  final Object error;
  AnErrorUI(this.error);

  @override
  Widget build(BuildContext context) {
    print("ERROR: $error");
    return Center(child: AText("Something went wrong."));
  }
}
