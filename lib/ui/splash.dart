import 'package:eye_visual/constants.dart';
import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:eye_visual/ui/authentication.dart';
import 'package:eye_visual/ui/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashUI extends StatefulWidget {
  @override
  _SplashUIState createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> {
  int _check = 121;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await [Permission.camera, Permission.storage, Permission.photos].request();
      final FirebaseAuth auth = FirebaseAuth.instance;
      SharedPreferences preferences = await SharedPreferences.getInstance();

      if ((preferences.getInt("PREF_GG") ?? -1) < _check) {
        await GoogleSignIn().signOut();
        await auth.signOut();
        await preferences.setInt("PREF_GG", _check);
        navigateFinish(context, AuthenticationUI());
        return;
      }

      if (auth.currentUser != null) {
        Global.narrationSpeed = preferences.getDouble(PREF_NARRATION_SPEED_KEY) ?? 0.8;
        Global.language = preferences.getString(PREF_LANGUAGE_KEY) ?? "en";
        navigateFinish(context, DashboardUI());
        return;
      }

      await GoogleSignIn().signOut();
      await auth.signOut();
      navigateFinish(context, AuthenticationUI());
    });
  }

  @override
  Widget build(BuildContext context) {
    final String logoAsset = MediaQuery.of(context).platformBrightness == Brightness.dark ? "assets/logo-w.png" : "assets/logo.png";
    return AScaffold(body: Center(child: Image.asset(logoAsset)));
  }
}
