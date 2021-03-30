import 'dart:io';

import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class AButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool signInButton;
  final bool noMargin;
  final Function() onPressed;
  AButton({@required this.label, this.icon, this.color, this.onPressed, this.signInButton = false, this.noMargin = false});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    TextStyle textStyle = Platform.isIOS ? CupertinoTheme.of(context).textTheme.actionTextStyle : Theme.of(context).textTheme.button;
    textStyle = textStyle.copyWith(color: isDarkMode ? (signInButton ? TEXT_COLOR_DARK : TEXT_COLOR) : (signInButton ? TEXT_COLOR : TEXT_COLOR_DARK));

    final Widget child = Row(children: [
      if (icon != null || signInButton) Padding(padding: EdgeInsets.only(right: DEFAULT_MARGIN), child: signInButton ? AnImageIcon("assets/google.png") : AnIcon(icon, button: true)),
      Expanded(child: AText(Platform.isIOS ? label : label.toUpperCase(), textAlign: TextAlign.center, maxLines: 1, style: textStyle)),
    ]);

    final EdgeInsetsGeometry margin = EdgeInsets.symmetric(vertical: DEFAULT_MARGIN * 0.5, horizontal: noMargin ? 0 : DEFAULT_MARGIN);
    final EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: DEFAULT_MARGIN, horizontal: DEFAULT_MARGIN * 3);
    Color buttonColor = isDarkMode ? (signInButton ? CARD_COLOR_DARK : color) : (signInButton ? CARD_COLOR : color);
    Widget buttonWidget;

    if (Platform.isIOS) {
      buttonWidget = CupertinoButton(padding: padding, child: child, onPressed: onPressed, color: buttonColor ?? CupertinoTheme.of(context).primaryColor);
    } else {
      buttonWidget = RaisedButton(padding: padding, child: child, onPressed: onPressed, color: buttonColor);
    }

    return Container(margin: margin, child: buttonWidget);
  }
}

class AVerticalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Function() onPressed;
  AVerticalButton({@required this.label, this.icon, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    TextStyle textStyle = Platform.isIOS ? CupertinoTheme.of(context).textTheme.actionTextStyle : Theme.of(context).textTheme.button;
    textStyle = textStyle.copyWith(color: isDarkMode ? TEXT_COLOR : TEXT_COLOR_DARK);

    final Widget child = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (icon != null) Padding(padding: EdgeInsets.only(bottom: DEFAULT_MARGIN * 0.5), child: AnIcon(icon, button: true)),
      AText(Platform.isIOS ? label : label.toUpperCase(), textAlign: TextAlign.center, maxLines: 2, style: textStyle),
    ]);

    final EdgeInsetsGeometry margin = EdgeInsets.symmetric(vertical: DEFAULT_MARGIN * 0.5, horizontal: DEFAULT_MARGIN * 0.5);
    final EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: DEFAULT_MARGIN * 0.75, horizontal: DEFAULT_MARGIN);
    Widget buttonWidget;

    if (Platform.isIOS) {
      buttonWidget = CupertinoButton(padding: padding, child: child, onPressed: onPressed, color: color ?? CupertinoTheme.of(context).primaryColor);
    } else {
      buttonWidget = RaisedButton(padding: padding, child: child, onPressed: onPressed, color: color);
    }

    return Container(margin: margin, child: buttonWidget);
  }
}

class ATextButton extends StatelessWidget {
  final String label;
  final TextStyle style;
  final bool negative;
  final Function() onPressed;
  ATextButton({@required this.label, this.style, this.negative = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color color;

    if (isDarkMode) {
      color = negative ? NEGATIVE_COLOR_DARK : ACCENT_COLOR_DARK;
    } else {
      color = negative ? NEGATIVE_COLOR : ACCENT_COLOR;
    }

    TextStyle textStyle = Platform.isIOS ? CupertinoTheme.of(context).textTheme.actionTextStyle : Theme.of(context).textTheme.button;
    textStyle = textStyle.merge(style).copyWith(color: color);
    final Widget child = AText(Platform.isIOS ? label : label.toUpperCase(), textAlign: TextAlign.center, maxLines: 1, style: textStyle);
    final EdgeInsetsGeometry padding = EdgeInsets.zero;
    Widget buttonWidget;

    if (Platform.isIOS) {
      buttonWidget = CupertinoButton(padding: padding, child: child, onPressed: onPressed);
    } else {
      buttonWidget = FlatButton(padding: padding, child: child, onPressed: onPressed);
    }

    return Container(margin: padding, child: buttonWidget);
  }
}

class NegativeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onPressed;
  NegativeButton({@required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Color color = MediaQuery.of(context).platformBrightness == Brightness.dark ? NEGATIVE_COLOR_DARK : NEGATIVE_COLOR;
    return AButton(label: Platform.isIOS ? label : label.toUpperCase(), icon: icon, onPressed: onPressed, color: color);
  }
}

class AFloatingButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final String heroTag;
  AFloatingButton({@required this.heroTag, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color buttonColor;

    if (isDarkMode) {
      buttonColor = ACCENT_COLOR_DARK;
    } else {
      buttonColor = ACCENT_COLOR;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: FloatingActionButton(
        child: AnIcon(icon, button: true),
        heroTag: heroTag,
        backgroundColor: buttonColor,
        splashColor: Platform.isIOS ? Colors.transparent : null,
        onPressed: onPressed,
      ),
    );
  }
}

class AnIconButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  AnIconButton({@required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding = EdgeInsets.zero;
    final Color color = MediaQuery.of(context).platformBrightness == Brightness.dark ? ACCENT_COLOR_DARK : ACCENT_COLOR;
    final AnIcon child = AnIcon(icon, color: color);
    return Platform.isIOS ? CupertinoButton(padding: padding, child: child, onPressed: onPressed) : IconButton(padding: padding, icon: child, onPressed: onPressed);
  }
}

class AListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final Function() onTap;
  final bool last;
  AListTile({this.leading, this.title, this.subtitle, this.trailing, this.onTap, this.last = false});

  @override
  Widget build(BuildContext context) {
    Widget _widget;

    if (Platform.isIOS) {
      _widget = CupertinoListTile(leading: leading, title: title, subtitle: subtitle, trailing: trailing, onTap: onTap, border: last ? Border() : null);
    } else {
      _widget = ListTile(leading: leading, title: title, subtitle: subtitle, trailing: trailing, onTap: onTap);
    }

    return _widget;
  }
}
