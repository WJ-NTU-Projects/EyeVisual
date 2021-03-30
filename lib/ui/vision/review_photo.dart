import 'dart:io';

import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:eye_visual/ui/vision/extracted_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';

class ReviewPhotoUI extends StatelessWidget {
  final File imageFile;
  ReviewPhotoUI(this.imageFile);

  @override
  Widget build(BuildContext context) {
    final AText title = AText("Review Photo");

    return FutureBuilder(
      future: _fixImage(imageFile),
      builder: (context, AsyncSnapshot<File> snapshot) {
        if (snapshot.hasError) return AScaffold(title: title, body: AnErrorUI(snapshot.error), isScrollable: false);
        if (snapshot.connectionState != ConnectionState.done) return AScaffold(title: title, body: AWaitingUI(), isScrollable: false);

        final File fixedImageFile = snapshot.data;
        return AScaffold(
          title: title,
          isScrollable: false,
          body: Column(children: [
            Expanded(child: Image.file(fixedImageFile)),
            ADivider(),
            Row(children: [
              Expanded(child: AVerticalButton(icon: ManyIcons.save, label: "Save", onPressed: () => _onSavePressed(context, fixedImageFile))),
              Expanded(child: AVerticalButton(icon: ManyIcons.next, label: "Next", onPressed: () => _onNextPressed(context, fixedImageFile))),
            ])
          ]),
        );
      },
    );
  }

  Future<File> _fixImage(File originalFile) async {
    List<int> _originalBytes = await originalFile.readAsBytes();
    List<int> _compressedBytes = await FlutterImageCompress.compressWithList(_originalBytes);
    File _compressedFile = await originalFile.writeAsBytes(_compressedBytes);
    return _compressedFile;
  }

  void _onSavePressed(BuildContext context, File imageFile) {
    final String libraryLabel = Platform.isIOS ? "Library" : "Gallery";

    showModalSheet(context, (context) {
      return ModalActionSheet(message: "Save Location", actionList: [
        ModalAction(Icons.cloud, "Cloud Storage", () => _save(context, true, imageFile)),
        ModalAction(Icons.photo_library, "Photo $libraryLabel", () => _save(context, false, imageFile)),
      ]);
    });
  }

  void _onNextPressed(BuildContext context, File imageFile) {
    navigate(context, ExtractedTextUI(imageFile));
  }

  Future<void> _save(BuildContext context, bool cloud, File imageFile) async {
    BuildContext oldContext = context;
    showProgressDialog(context);
    final DateTime _now = DateTime.now();
    String _name = "${_now.year}-${_paddedTimeUnit(_now.month)}-${_paddedTimeUnit(_now.day)}_${_paddedTimeUnit(_now.hour)}${_paddedTimeUnit(_now.minute)}${_paddedTimeUnit(_now.second)}";

    if (cloud) {
      FirebaseAuth _auth = FirebaseAuth.instance;
      FirebaseStorage _storage = FirebaseStorage.instance;
      Reference ref = _storage.ref("${_auth.currentUser.uid}/$_name");

      try {
        await ref.putFile(imageFile).timeout(Duration(seconds: 5), onTimeout: () => throw ("Timeout"));
        hideProgressDialog(context);
        showADialog(context, (context) => ADialog(DialogType.OK, message: "File saved to cloud storage successfully.", onPressed: () => Navigator.pop(oldContext)));
      } catch (error) {
        hideProgressDialog(context);
        showADialog(context, (context) => ADialog(DialogType.OK, message: "File saved to cloud storage successfully.", onPressed: () => Navigator.pop(oldContext)));
      }
    } else {
      final String libraryLabel = Platform.isIOS ? "library" : "gallery";

      try {
        await GallerySaver.saveImage(imageFile.path, albumName: "EyeVisual").timeout(Duration(seconds: 5), onTimeout: () => throw ("Timeout"));
        hideProgressDialog(context);
        showADialog(context, (context) => ADialog(DialogType.OK, message: "File saved to photo $libraryLabel successfully.", onPressed: () => Navigator.pop(oldContext)));
      } catch (error) {
        hideProgressDialog(context);
        showADialog(context, (context) => ADialog(DialogType.OK, message: "File saved to photo $libraryLabel successfully.", onPressed: () => Navigator.pop(oldContext)));
      }
    }
  }

  String _paddedTimeUnit(int unit) {
    return unit.toString().padLeft(2, '0');
  }
}
