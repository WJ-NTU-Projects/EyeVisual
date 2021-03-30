import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

Future<void> showADialog(BuildContext context, WidgetBuilder builder) {
  return Platform.isIOS ? showCupertinoDialog(context: context, builder: builder) : showDialog(context: context, builder: builder);
}

void showErrorDialog(BuildContext context, dynamic error) {
  print("ERROR: $error");
  showADialog(context, (context) => ADialog(DialogType.OK, message: "Something went wrong."));
  //showPlatformDialog(context: context, builder: (context) => ADialog(DialogType.OK, message: ERROR_DEF));
}

void showProgressDialog(BuildContext context) {
  showADialog(context, (context) => ADialog(DialogType.PROGRESS));
}

Future<void> hideProgressDialog(BuildContext context) async {
  Navigator.pop(context);
}

Future<void> showModalSheet(BuildContext context, WidgetBuilder builder) {
  return Platform.isIOS ? showCupertinoModalPopup(context: context, builder: builder) : showModalBottomSheet(context: context, builder: builder);
}

Future<T> navigate<T extends Object>(BuildContext context, Widget targetPage, {bool root = false}) {
  final Route<T> route = Platform.isIOS ? CupertinoPageRoute(builder: (context) => targetPage) : MaterialPageRoute(builder: (context) => targetPage);
  return Navigator.of(context, rootNavigator: root).push(route);
}

Future<T> navigateFinish<T extends Object>(BuildContext context, Widget targetPage) {
  final Route<T> route = Platform.isIOS ? CupertinoPageRoute(builder: (context) => targetPage) : MaterialPageRoute(builder: (context) => targetPage);
  return Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
}

Border getNavBorder(BuildContext context) {
  final Color navBorderColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? DIVIDER_COLOR_DARK : DIVIDER_COLOR;
  return Border(bottom: BorderSide(color: navBorderColor, width: 0.0, style: BorderStyle.solid));
}

Color getCardColor2(BuildContext context) {
  return Platform.isIOS ? (MediaQuery.of(context).platformBrightness == Brightness.dark ? CARD_COLOR_DARK : CARD_COLOR) : Colors.transparent;
}

Color getColor(BuildContext context, ColorType type) {
  bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

  switch (type) {
    case ColorType.PRIMARY:
      return isDarkMode ? PRIMARY_COLOR_DARK : PRIMARY_COLOR;
    case ColorType.SLIVER:
      return isDarkMode ? SLIVER_COLOR_DARK : SLIVER_COLOR;
    case ColorType.ACCENT:
      return isDarkMode ? ACCENT_COLOR_DARK : ACCENT_COLOR;
    case ColorType.CARD:
      return isDarkMode ? CARD_COLOR_DARK : CARD_COLOR;
    case ColorType.TILE:
      return Platform.isIOS ? (isDarkMode ? CARD_COLOR_DARK : CARD_COLOR) : Colors.transparent;
    case ColorType.DIVIDER:
      return isDarkMode ? DIVIDER_COLOR_DARK : DIVIDER_COLOR;
    case ColorType.POSITIVE:
      return isDarkMode ? POSITIVE_COLOR_DARK : POSITIVE_COLOR;
    case ColorType.NEGATIVE:
      return isDarkMode ? NEGATIVE_COLOR_DARK : NEGATIVE_COLOR;
    case ColorType.TEXT:
      return isDarkMode ? TEXT_COLOR_DARK : TEXT_COLOR;
    case ColorType.BUTTON_TEXT:
      return isDarkMode ? TEXT_COLOR : TEXT_COLOR_DARK;
    case ColorType.INACTIVE:
      return isDarkMode ? INACTIVE_COLOR_DARK : INACTIVE_COLOR;
    default:
      return isDarkMode ? PRIMARY_COLOR_DARK : PRIMARY_COLOR;
  }
}
