import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eye_visual/constants.dart';
import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:eye_visual/ui/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String logoAsset = MediaQuery.of(context).platformBrightness == Brightness.dark ? "assets/logo-w.png" : "assets/logo.png";

    return AScaffold(
      body: Column(children: [
        Expanded(child: Center(child: Image.asset(logoAsset, width: 256.0))),
        AButton(label: "Sign in with Google", signInButton: true, onPressed: () => _onGooglePressed(context)),
        SizedBox(height: DEFAULT_MARGIN * 3),
      ]),
    );
  }

  void _onGooglePressed(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final GoogleSignInAccount googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) return;
      final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
      showProgressDialog(context);
      await auth.signInWithCredential(GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken));
      final User user = auth.currentUser;

      if (user == null) {
        await auth.signOut();
        await googleSignIn.signOut();
        hideProgressDialog(context);
        showErrorDialog(context, "User is null.");
        return;
      }

      DocumentSnapshot snapshot = await firestore.collection(FS_USERS).doc(user.uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data();
        _onAuthenticated(context, data["narration_speed"], data["language"]);
        return;
      }

      Map<String, dynamic> data = {"narration_speed": 0.8, "language": "en"};
      await firestore.collection(FS_USERS).doc(user.uid).set(data);
      _onAuthenticated(context, 0.8, "en");
    } catch (error) {
      hideProgressDialog(context);
      showErrorDialog(context, error);
    }
  }

  void _onAuthenticated(BuildContext context, double narrationSpeed, String language) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(PREF_NARRATION_SPEED_KEY, narrationSpeed);
    await preferences.setString(PREF_LANGUAGE_KEY, language);
    Global.narrationSpeed = narrationSpeed;
    Global.language = language;
    print(Global.narrationSpeed);
    navigateFinish(context, DashboardUI());
  }
}
