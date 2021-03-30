import 'dart:io';
import 'dart:ui';

import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalActionSheet extends StatefulWidget {
  final String message;
  final List<ModalAction> actionList;
  final Function() closeAction;
  final Set<int> negativeOverride;
  ModalActionSheet({@required this.message, @required this.actionList, this.closeAction, this.negativeOverride});

  @override
  _ModalActionSheetState createState() => _ModalActionSheetState();
}

class _ModalActionSheetState extends State<ModalActionSheet> {
  @override
  Widget build(BuildContext context) {
    final List<ModalAction> actionList = widget.actionList;
    final List<Widget> widgetList = [];
    final Set<int> negativeOverride = widget.negativeOverride;
    if (!Platform.isIOS) widgetList.add(Padding(padding: EdgeInsets.all(DEFAULT_MARGIN), child: AText(widget.message, textAlign: TextAlign.center)));

    final bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color primaryColor = CupertinoTheme.of(context).primaryColor;
    final Color negativeColor = isDarkMode ? NEGATIVE_COLOR_DARK : NEGATIVE_COLOR;

    for (int i = 0; i < actionList.length; i++) {
      final ModalAction action = actionList[i];
      final Color color = (negativeOverride != null && negativeOverride.contains(i)) ? negativeColor : primaryColor;
      final CupertinoButton cupertinoChild = CupertinoButton(child: AText(action.label, style: TextStyle(color: color)), onPressed: action.onTap);
      final ListTile materialChild = ListTile(leading: AnIcon(action.icon), title: AText(action.label), onTap: action.onTap);
      widgetList.add(Platform.isIOS ? cupertinoChild : materialChild);
    }

    Widget actionSheet;

    if (Platform.isIOS) {
      final Widget cancelButton = CupertinoButton(child: AText("Cancel", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)), onPressed: () => _onCancel(context));
      actionSheet = CupertinoActionSheet(message: Text(widget.message), cancelButton: cancelButton, actions: widgetList);
    } else {
      widgetList.add(ADivider());
      widgetList.add(ListTile(leading: AnIcon(Icons.cancel), title: AText("Cancel"), onTap: () => _onCancel(context)));

      final Color cardColor = isDarkMode ? CARD_COLOR_DARK : CARD_COLOR;
      final Widget child = Container(color: cardColor, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgetList));
      actionSheet = Wrap(children: [child]);
    }

    return actionSheet;
  }

  void _onCancel(BuildContext context) {
    if (widget.closeAction != null) widget.closeAction();
    Navigator.of(context).pop();
  }
}

class ModalAction {
  final IconData icon;
  final String label;
  final Function() onTap;
  ModalAction(this.icon, this.label, this.onTap);
}
