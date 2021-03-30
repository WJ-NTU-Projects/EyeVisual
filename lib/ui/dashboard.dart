import 'dart:io';

import 'package:eye_visual/constants.dart';
import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:eye_visual/ui/authentication.dart';
import 'package:eye_visual/ui/vision/review_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardUI extends StatefulWidget {
  @override
  _DashboardUIState createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  bool _refresh = true;
  List<List<dynamic>> _imageList = [];
  bool _pickerActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getStorageImages());
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser;
    final String logoAsset = MediaQuery.of(context).platformBrightness == Brightness.dark ? "assets/logo-w.png" : "assets/logo.png";

    final Widget imageDisplayWidget = Scrollbar(
      child: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.zero,
        children: List.generate(_imageList.length, (index) {
          final item = _imageList[index];

          return GestureDetector(
            child: Padding(padding: EdgeInsets.all(2), child: FadeInImage(image: NetworkImage(item[1]), placeholder: AssetImage(logoAsset), fit: BoxFit.fitWidth)),
            onTap: _pickerActive ? null : () => _onListItemTapped(context, item[0], item[1]),
          );
        }),
      ),
    );

    final Widget emptyStorageWidget = Padding(padding: EdgeInsets.symmetric(vertical: DEFAULT_MARGIN), child: Center(child: AText("Your cloud storage is empty.")));
    final Widget child = _imageList.isNotEmpty ? imageDisplayWidget : (_refresh ? AWaitingUI() : emptyStorageWidget);
    final Widget circleAvatar = CircleAvatar(backgroundImage: NetworkImage(user.photoURL), backgroundColor: Colors.transparent);
    String libraryLabel;
    Widget action;

    if (Platform.isIOS) {
      libraryLabel = "Library";
      action = Builder(builder: (context) => Padding(padding: EdgeInsets.only(bottom: DEFAULT_MARGIN * 0.25), child: CupertinoButton(padding: EdgeInsets.zero, child: circleAvatar, onPressed: _pickerActive ? null : () => _onProfilePressed(context, user))));
    } else {
      libraryLabel = "Gallery";
      action = Builder(builder: (context) => Padding(padding: EdgeInsets.only(right: DEFAULT_MARGIN), child: InkWell(child: circleAvatar, onTap: _pickerActive ? null : () => _onProfilePressed(context, user))));
    }

    return AScaffold(
      title: AText("EyeVisual"),
      action: action,
      isScrollable: false,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: child),
        ADivider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DEFAULT_MARGIN * 0.5),
          child: Row(children: [
            Expanded(child: AVerticalButton(icon: ManyIcons.photos, label: libraryLabel, onPressed: _pickerActive ? null : () => _getPhoto(context, ImageSource.gallery))),
            Expanded(child: AVerticalButton(icon: ManyIcons.camera, label: "Camera", onPressed: _pickerActive ? null : () => _getPhoto(context, ImageSource.camera))),
          ]),
        ),
      ]),
    );
  }

  void _onProfilePressed(BuildContext context, User user) {
    showModalSheet(context, (context) {
      return Container(
        decoration: BoxDecoration(color: getColor(context, ColorType.CARD), borderRadius: Platform.isIOS ? BorderRadius.circular(DEFAULT_MARGIN) : null),
        padding: EdgeInsets.symmetric(vertical: DEFAULT_MARGIN * 2, horizontal: DEFAULT_MARGIN * 2),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(child: ATitleText("Account"), onLongPress: () => _debug(context)),
          SizedBox(height: DEFAULT_MARGIN * 2),
          ProfileCard(name: user.displayName, photo: user.photoURL, role: user.email),
          SizedBox(height: DEFAULT_MARGIN * 2),
          AButton(label: "Sign Out", onPressed: () => _onSignOutPressed(context), noMargin: true),
          SizedBox(height: DEFAULT_MARGIN * 0.5),
          AText("Ver. ${Global.version}", style: TextStyle(fontSize: 12, color: CAPTION_COLOR).apply(fontSizeFactor: 1.0)),
        ]),
      );
    });
  }

  void _debug(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool current = preferences.getBool(PREF_OCR_KEY) ?? true;
    bool updated = !current;
    await preferences.setBool(PREF_OCR_KEY, updated);
    String message = updated ? "Using ML Kit" : "Using Tessaract";
    showADialog(context, (context) => ADialog(DialogType.OK, message: message));
  }

  void _onSignOutPressed(BuildContext context) async {
    final String message = "Are you sure you want to sign out?";
    showADialog(context, (context) => ADialog(DialogType.YES_NO, message: message, onPressed: () => _signOut(context)));
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

  void _getStorageImages() async {
    Reference ref = FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser.uid);
    List<Reference> _fileList = (await ref.listAll()).items;
    List<List<dynamic>> _retList = [];

    for (Reference file in _fileList) {
      String url = await file.getDownloadURL();
      _retList.add([file, url]);
    }

    _retList = _retList.reversed.toList();
    if (!mounted) return;
    setState(() {
      _imageList = _retList;
      _refresh = false;
    });
  }

  void _getPhoto(BuildContext context, ImageSource source) async {
    try {
      setState(() => _pickerActive = true);
      final file = await ImagePicker().getImage(source: source);
      setState(() => _pickerActive = false);
      if (file == null) return;
      navigate(context, ReviewPhotoUI(File(file.path)), root: true).then((value) => _getStorageImages());
    } catch (error) {
      print(error);
    }
  }

  void _onListItemTapped(BuildContext context, Reference file, String url) async {
    showModalSheet(context, (context) {
      return ModalActionSheet(
        message: "Actions",
        actionList: [
          ModalAction(Icons.photo, "View", () => _viewImage(context, url)),
          ModalAction(Icons.delete, "Delete", () => _askDeleteImage(context, file)),
        ],
        negativeOverride: Set.of([1]),
      );
    });
  }

  void _viewImage(BuildContext context, String url) async {
    showProgressDialog(context);

    try {
      Response response = await get(url);
      final String path = join((await getTemporaryDirectory()).path, "${DateTime.now()}.png");
      final File imageFile = File(path);
      await imageFile.writeAsBytes(response.bodyBytes);
      hideProgressDialog(context);
      Navigator.pop(context);
      navigate(context, ReviewPhotoUI(imageFile), root: true);
      //Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewPhotoUI(imageFile: _imageFile, saved: 2)));
    } catch (error) {
      hideProgressDialog(context);
      showErrorDialog(context, error);
    }
  }

  void _askDeleteImage(BuildContext context, Reference file) {
    BuildContext oldContext = context;
    showADialog(context, (context) => ADialog(DialogType.YES_NO, message: "Are you sure you want to delete this photo?", onPressed: () => _deletePhoto(oldContext, file)));
  }

  void _deletePhoto(BuildContext context, Reference file) async {
    showProgressDialog(context);

    try {
      await file.delete();
      hideProgressDialog(context);
      Navigator.pop(context);
      _getStorageImages();
    } catch (error) {
      showErrorDialog(context, error);
    }
  }
}
