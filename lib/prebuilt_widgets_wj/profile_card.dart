import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String photo;
  final String role;
  ProfileCard({@required this.name, @required this.photo, @required this.role});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(color: Platform.isIOS ? Colors.transparent : (isDarkMode ? CARD_COLOR_DARK : CARD_COLOR), borderRadius: BorderRadius.circular(8.0)),
      child: Row(children: [
        CircleAvatar(backgroundImage: NetworkImage(photo), radius: DEFAULT_ICON_SIZE * 1.2, backgroundColor: Colors.transparent),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DEFAULT_MARGIN),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AText(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: DEFAULT_MARGIN * 0.25),
            AText(role, style: TextStyle(fontSize: 14)),
          ]),
        ),
      ]),
    );
  }
}
