import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:eye_visual/constants.dart';
import 'package:eye_visual/prebuilt_widgets_wj/prebuilt_widgets_wj.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class ExtractedTextUI extends StatefulWidget {
  final File imageFile;
  ExtractedTextUI(this.imageFile);

  @override
  _ExtractedTextUIState createState() => _ExtractedTextUIState();
}

class _ExtractedTextUIState extends State<ExtractedTextUI> {
  FlutterTts _flutterTts;
  String _parsedText;
  String _parsedTextEN;
  String _language = "en";

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runFirst());
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding = EdgeInsets.all(DEFAULT_MARGIN);
    Widget child;

    if (_parsedText != null) {
      child = Scrollbar(child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Padding(padding: padding, child: Center(child: AText(_parsedText, style: TextStyle(fontSize: 20))))));
    } else {
      child = Padding(padding: padding, child: AWaitingUI());
    }

    Function() f = _parsedText != null ? () => _onReadOutTextPressed(context, _parsedText.isNotEmpty ? _parsedText : "No text found.", _language) : null;
    String languageLabel = _language == "zh" ? "中文" : "English";

    return AScaffold(
      title: AText("Extracted Text"),
      isScrollable: false,
      body: Column(children: [
        Expanded(child: child),
        ADivider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DEFAULT_MARGIN * 0.5),
          child: Row(children: [
            Expanded(child: AVerticalButton(icon: ManyIcons.sound, label: "Read Out Text", onPressed: f), flex: 2),
            Expanded(child: AVerticalButton(icon: ManyIcons.language, label: languageLabel, onPressed: _parsedText != null ? () => _onLanguagePressed(context) : null)),
          ]),
        ),
      ]),
    );
  }

  Future<void> _test() async {
    File imageFile = widget.imageFile;
    http.ByteStream stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();
    String uploadURL = "http://172.21.148.163:5000";
    Uri uri = Uri.parse(uploadURL);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('image', stream, length, filename: basename(imageFile.path), contentType: MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);

    response.stream.transform(utf8.decoder).listen((value) {
      List<dynamic> stringList = json.decode(value);
      String text = "";
      for (String s in stringList) text += s;
      if (text.isEmpty) text = "There is no text found.";

      setState(() {
        _parsedTextEN = text;
        _parsedText = text;
      });
    });
  }

  void _runFirst() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool useMLKit = preferences.getBool(PREF_OCR_KEY) ?? true;

    try {
      if (!useMLKit) {
        await _test();
        return;
      }

      final FirebaseVisionImage _visionImage = FirebaseVisionImage.fromFile(widget.imageFile);
      final TextRecognizer _textRecognizer = FirebaseVision.instance.textRecognizer();
      final VisionText _visionText = await _textRecognizer.processImage(_visionImage);
      String text = "";

      for (TextBlock block in _visionText.blocks) {
        for (TextLine line in block.lines) text += line.text + "\n";
        text += "\n";
      }

      _textRecognizer.close();
      if (text.isEmpty) text = "There is no text found.";

      setState(() {
        _parsedTextEN = text;
        _parsedText = text;
      });
    } catch (error) {
      print("ERROR: $error");

      setState(() {
        _parsedTextEN = "Something went wrong.";
        _parsedText = "Something went wrong.";
      });
    }
  }

  void _runTranslation(String language) async {
    try {
      await _flutterTts.stop();
      String text = await translate(_parsedTextEN, language);

      setState(() {
        _language = language;
        _parsedText = text;
      });
    } catch (error) {
      print("ERROR: $error");
      setState(() => _parsedText = "Something went wrong.");
    }
  }

  Future<String> translate(String text, String language) async {
    String translateLanguage = language == "zh" ? "zh-cn" : "en";
    if (translateLanguage == "en") return _parsedTextEN;
    Translation translation = await GoogleTranslator().translate(text, to: translateLanguage);
    return translation.text;
  }

  void _onReadOutTextPressed(BuildContext context, String text, String language) async {
    double narrationSpeed = Global.narrationSpeed;

    if (Platform.isIOS) {
      int comparison = (narrationSpeed).compareTo(0.8);

      if (comparison > 0) {
        narrationSpeed = 0.55;
      } else if (comparison < 0) {
        narrationSpeed = 0.35;
      } else {
        narrationSpeed = 0.45;
      }
    }

    await _flutterTts.setLanguage(language == "zh" ? "zh-CN" : "en-GB");
    await _flutterTts.setSpeechRate(narrationSpeed);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSharedInstance(false);
    await _flutterTts.speak(text);
  }

  void _onLanguagePressed(BuildContext context) {
    showModalSheet(context, (context) {
      return ModalActionSheet(message: "Language", actionList: [
        ModalAction(Icons.language, "English", () {
          Navigator.pop(context);
          setState(() => _parsedText = null);
          _runTranslation("en");
        }),
        ModalAction(Icons.language, "Chinese", () {
          Navigator.pop(context);
          setState(() => _parsedText = null);
          _runTranslation("zh");
        }),
      ]);
    });
  }
}
