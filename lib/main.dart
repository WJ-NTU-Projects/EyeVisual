import 'package:eye_visual/constants.dart';
import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:eye_visual/ui/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:package_info/package_info.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) => FlutterError.dumpErrorToConsole(details);
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String title = "EyeVisual";

    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return AnApp(title: title, home: SafeArea(child: AnErrorUI(snapshot.error)));
        if (snapshot.connectionState != ConnectionState.done) return AnApp(title: title, home: SafeArea(child: Center(child: Image.asset("assets/logo.png"))));
        return AnApp(title: title, home: SplashUI());
      },
    );
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    FlutterTts tts = FlutterTts();
    print((await tts.getLanguages));
    Global.version = packageInfo.version;
  }
}
