import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class AnIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool button;
  AnIcon(this.icon, {this.color, this.button = false});

  @override
  Widget build(BuildContext context) {
    final Color iconColor = color ?? (MediaQuery.of(context).platformBrightness == Brightness.dark ? (button ? TEXT_COLOR : TEXT_COLOR_DARK) : (button ? TEXT_COLOR_DARK : TEXT_COLOR));
    return Icon(icon, size: _getScaledIconSize(context), color: iconColor);
  }
}

class AnImageIcon extends StatelessWidget {
  final String url;
  AnImageIcon(this.url);

  @override
  Widget build(BuildContext context) {
    final double size = _getScaledIconSize(context);
    return Image.asset(url, width: size, height: size);
  }
}

double _getScaledIconSize(BuildContext context) {
  double scaleFactor = MediaQuery.textScaleFactorOf(context);
  return DEFAULT_ICON_SIZE * scaleFactor;
}
