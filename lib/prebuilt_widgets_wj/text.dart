import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class AText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final TextAlign textAlign;
  final int maxLines;
  AText(this.data, {this.style, this.textAlign, this.maxLines});

  @override
  Widget build(BuildContext context) {
    final Color textColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? TEXT_COLOR_DARK : TEXT_COLOR;
    TextStyle finalStyle;

    if (style != null) {
      finalStyle = (style.color == null) ? style.copyWith(color: textColor) : style;
    } else {
      finalStyle = TextStyle(color: textColor);
    }

    return Text(data, style: finalStyle, textAlign: textAlign, maxLines: maxLines);
  }
}

class ATitleText extends StatelessWidget {
  final String data;
  ATitleText(this.data);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor = Platform.isIOS ? (isDarkMode ? TEXT_COLOR_DARK : TEXT_COLOR) : (isDarkMode ? ACCENT_COLOR_DARK : ACCENT_COLOR);
    return Text(data, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w600), maxLines: 1);
  }
}

class ASubtitleText extends StatelessWidget {
  final String data;
  ASubtitleText(this.data);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    //final Color textColor = Platform.isIOS ? (isDarkMode ? TEXT_COLOR_DARK : TEXT_COLOR) : (isDarkMode ? ACCENT_COLOR_DARK : ACCENT_COLOR);
    final Color textColor = isDarkMode ? TEXT_COLOR_DARK : TEXT_COLOR;
    return Text(data, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w600), maxLines: 1);
  }
}

class ATextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType inputType;
  final int limit;
  ATextField({@required this.controller, this.placeholder, this.inputType, this.limit});

  @override
  _ATextFieldState createState() => _ATextFieldState();
}

class _ATextFieldState extends State<ATextField> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: DEFAULT_MARGIN * 0.75, horizontal: DEFAULT_MARGIN * 0.5);
    Widget textField;

    if (Platform.isIOS) {
      textField = CupertinoTextField(padding: padding, controller: _controller, placeholder: widget.placeholder, maxLength: widget.limit, keyboardType: widget.inputType);
    } else {
      final InputDecoration decoration = InputDecoration(contentPadding: padding, hintText: widget.placeholder);
      textField = TextField(decoration: decoration, controller: _controller, maxLength: widget.limit, keyboardType: widget.inputType);
    }

    return textField;
  }
}
