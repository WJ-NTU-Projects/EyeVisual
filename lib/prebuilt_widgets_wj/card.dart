import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class ACard extends StatelessWidget {
  final Widget child;
  ACard(this.child);

  @override
  Widget build(BuildContext context) {
    final Color cardColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? CARD_COLOR_DARK : CARD_COLOR;
    final EdgeInsetsGeometry padding = EdgeInsets.all(DEFAULT_MARGIN);
    final Widget paddedChild = Padding(padding: padding, child: child);
    Widget card;

    if (Platform.isIOS) {
      card = CupertinoButton(padding: padding, child: child, onPressed: null, disabledColor: cardColor, color: cardColor);
    } else {
      card = Card(child: paddedChild, color: cardColor);
    }

    return Container(margin: padding, child: card);
  }
}
