import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eye_visual/constants.dart';
import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:eye_visual/ui/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsUI extends StatefulWidget {
  @override
  _SettingsUIState createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  final User _user = FirebaseAuth.instance.currentUser;
  double _narrationSpeed = Global.narrationSpeed;
  String _language = Global.language;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle captionStyle = TextStyle(color: CAPTION_COLOR);
    final AText narrationText = AText(_getNarrationSpeedLabel(_narrationSpeed), style: captionStyle);

    final AListTile narrationSpeedTile = AListTile(
      leading: AnIcon(ManyIcons.speed),
      title: AText("Narration Speed"),
      trailing: Platform.isIOS ? narrationText : null,
      subtitle: Platform.isIOS ? null : narrationText,
      onTap: () => _onNarrationSpeedTapped(context),
    );

    final Widget languageText = AText(_getLanguageLabel(_language), style: captionStyle);

    final AListTile extractedLanguageTile = AListTile(
      leading: AnIcon(ManyIcons.language),
      title: AText("Extracted Text Language"),
      trailing: Platform.isIOS ? languageText : null,
      subtitle: Platform.isIOS ? null : languageText,
      onTap: () => _onLanguageTapped(context),
    );

    final AListTile textSizeTile = AListTile(
      leading: AnIcon(Platform.isIOS ? CupertinoIcons.device_phone_portrait : Icons.format_size),
      title: AText("App Settings"),
      subtitle: AText("Shortcut to device settings", style: Platform.isIOS ? TextStyle(fontSize: 14, color: CAPTION_COLOR) : null),
      last: true,
      onTap: () => AppSettings.openDisplaySettings(),
    );

    final Color negativeColor = getColor(context, ColorType.NEGATIVE);

    final AListTile clearStorageTile = AListTile(
      leading: AnIcon(ManyIcons.delete, color: negativeColor),
      title: AText("Clear Cloud Storage", style: TextStyle(color: negativeColor)),
      trailing: _deleting ? AProgressIndicator() : null,
      last: true,
      onTap: _deleting ? null : () => _onClearStoragePressed(context),
    );

    final Widget child = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      ProfileCard(name: _user.displayName, photo: _user.photoURL, role: _user.email),
      if (Platform.isIOS) ADivider(),
      Container(color: getColor(context, ColorType.TILE), child: Column(children: [narrationSpeedTile, textSizeTile])),
      if (Platform.isIOS) ADivider(),
      SizedBox(height: DEFAULT_MARGIN * 1.5),
      AButton(label: "Sign Out", onPressed: () => _onSignOutPressed(context)),
      //ATextButton(label: "Sign Out", style: TextStyle(fontSize: Platform.isIOS ? null : 16.0, fontWeight: FontWeight.w600), onPressed: () => _onSignOutPressed(context)),
    ]);

    return Platform.isIOS ? AScaffold(title: AText("Settings"), body: child, action: AnIconButton(icon: ManyIcons.cloudUpload, onPressed: () => _debug(context))) : Scrollbar(child: SingleChildScrollView(child: child));
  }

  void _debug(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool current = preferences.getBool(PREF_OCR_KEY) ?? true;
    bool updated = !current;
    await preferences.setBool(PREF_OCR_KEY, updated);
    String message = updated ? "Using ML Kit" : "Using Tessaract";
    showADialog(context, (context) => ADialog(DialogType.OK, message: message));
  }

  String _getNarrationSpeedLabel(double value) {
    return value.compareTo(1.1) == 0 ? "Fast" : (value.compareTo(0.5) == 0 ? "Slow" : "Normal");
  }

  String _getLanguageLabel(String value) {
    return value == "zh" ? "Chinese" : "English";
  }

  void _onNarrationSpeedTapped(BuildContext context) {
    showModalSheet(context, (context) {
      return ModalActionSheet(message: "Narration Speed", actionList: [
        ModalAction(Icons.looks_one, "Slow", () => _onNarrationSpeedChanged(context, 0.5)),
        ModalAction(Icons.looks_two, "Normal", () => _onNarrationSpeedChanged(context, 0.8)),
        ModalAction(Icons.looks_3, "Fast", () => _onNarrationSpeedChanged(context, 1.1)),
      ]);
    });
  }

  Future<void> _onNarrationSpeedChanged(BuildContext context, double value) async {
    showProgressDialog(context);

    try {
      Map<String, dynamic> data = {"narration_speed": value};
      await FirebaseFirestore.instance.collection(FS_USERS).doc(_user.uid).update(data);
      await (await SharedPreferences.getInstance()).setDouble(PREF_NARRATION_SPEED_KEY, value);
      Global.narrationSpeed = value;
      hideProgressDialog(context);
      Navigator.pop(context);
      setState(() => _narrationSpeed = value);
    } catch (error) {
      hideProgressDialog(context);
    }
  }

  void _onLanguageTapped(BuildContext context) {
    showModalSheet(context, (context) {
      return ModalActionSheet(message: "Extracted Text Language", actionList: [
        ModalAction(Icons.language, "English", () => _changeLanguage(context, "en")),
        ModalAction(Icons.language, "Chinese", () => _changeLanguage(context, "zh")),
      ]);
    });
  }

  Future<void> _changeLanguage(BuildContext context, String value) async {
    showProgressDialog(context);

    try {
      Map<String, dynamic> data = {"language": value};
      await FirebaseFirestore.instance.collection(FS_USERS).doc(_user.uid).update(data);
      await (await SharedPreferences.getInstance()).setString(PREF_LANGUAGE_KEY, value);
      Global.language = value;
      hideProgressDialog(context);
      Navigator.pop(context);
      setState(() => _language = value);
    } catch (error) {
      hideProgressDialog(context);
    }
  }

  void _onClearStoragePressed(BuildContext context) {
    final String message = "Are you sure you want to delete all photos in your cloud storage?";

    showModalSheet(context, (context) {
      return ModalActionSheet(message: message, actionList: [ModalAction(Icons.exit_to_app, "Delete All Photos", () => _clearCloudStorageData(context))], negativeOverride: Set.of([0]));
    });
  }

  void _clearCloudStorageData(BuildContext context) async {
    setState(() => _deleting = true);
    try {
      ListResult result = await FirebaseStorage.instance.ref(_user.uid).listAll();
      for (Reference file in result.items) await file.delete();
      setState(() => _deleting = false);
      showADialog(context, (context) => ADialog(DialogType.OK, message: "All photos in your cloud storage have been deleted successfully.", onPressed: () => Navigator.pop(context)));
    } catch (error) {
      showErrorDialog(context, error);
      setState(() => _deleting = false);
    }
  }

  void _onSignOutPressed(BuildContext context) async {
    final String message = "Are you sure you want to sign out?";

    showModalSheet(context, (context) {
      return ModalActionSheet(message: message, actionList: [ModalAction(Icons.exit_to_app, "Sign Out", () => _signOut(context))], negativeOverride: Set.of([0]));
    });
  }

  void _signOut(BuildContext context) async {
    showProgressDialog(context);

    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      hideProgressDialog(context);
      navigateFinish(context, AuthenticationUI());
    } catch (error) {
      hideProgressDialog(context);
      showErrorDialog(context, error);
    }
  }
}
