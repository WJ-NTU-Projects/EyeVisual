import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class AnApp extends StatelessWidget {
  final String title;
  final Widget home;
  AnApp({@required this.title, @required this.home});

  @override
  Widget build(BuildContext context) {
    Diagnosticable theme;
    Diagnosticable darkTheme;

    if (Platform.isIOS) {
      theme = CupertinoThemeData(
        primaryColor: CupertinoDynamicColor.withBrightness(color: ACCENT_COLOR, darkColor: ACCENT_COLOR_DARK),
        primaryContrastingColor: CupertinoDynamicColor.withBrightness(color: TEXT_COLOR, darkColor: TEXT_COLOR_DARK),
        barBackgroundColor: CupertinoDynamicColor.withBrightness(color: CARD_COLOR, darkColor: CARD_COLOR_DARK),
        scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(color: PRIMARY_COLOR, darkColor: PRIMARY_COLOR_DARK),
        //textTheme: CupertinoTextThemeData(primaryColor: CupertinoDynamicColor.withBrightness(color: TEXT_COLOR, darkColor: TEXT_COLOR_DARK)),
      );
    } else {
      theme = ThemeData(
        primaryColor: PRIMARY_COLOR,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: PRIMARY_COLOR, selectedItemColor: ACCENT_COLOR, unselectedItemColor: INACTIVE_COLOR),
        accentColor: ACCENT_COLOR,
        scaffoldBackgroundColor: PRIMARY_COLOR,
        buttonTheme: ButtonThemeData(buttonColor: ACCENT_COLOR, textTheme: ButtonTextTheme.primary),
      );

      darkTheme = ThemeData(
        primaryColor: PRIMARY_COLOR_DARK,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: PRIMARY_COLOR_DARK, selectedItemColor: ACCENT_COLOR_DARK, unselectedItemColor: INACTIVE_COLOR_DARK),
        accentColor: ACCENT_COLOR_DARK,
        scaffoldBackgroundColor: PRIMARY_COLOR_DARK,
        buttonTheme: ButtonThemeData(buttonColor: ACCENT_COLOR_DARK, textTheme: ButtonTextTheme.primary),
      );
    }

    return Platform.isIOS ? CupertinoApp(title: title, home: home, theme: theme) : MaterialApp(title: title, home: home, theme: theme, darkTheme: darkTheme);
  }
}
