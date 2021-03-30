import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManyIcons {
  static IconData checkCircled = Platform.isIOS ? CupertinoIcons.checkmark_circle_fill : Icons.check_circle;
  static IconData exclaimationTriangle = Platform.isIOS ? CupertinoIcons.exclamationmark_triangle_fill : Icons.warning;
  static IconData person = Platform.isIOS ? CupertinoIcons.person_solid : Icons.person;
  static IconData clock = Platform.isIOS ? CupertinoIcons.clock : Icons.access_time;
  static IconData location = Platform.isIOS ? CupertinoIcons.location_solid : Icons.location_on;
  static IconData home = Platform.isIOS ? CupertinoIcons.home : Icons.home;
  static IconData settings = Platform.isIOS ? CupertinoIcons.settings : Icons.settings;
  static IconData photos = Platform.isIOS ? CupertinoIcons.photo_fill_on_rectangle_fill : Icons.photo_library;
  static IconData camera = Platform.isIOS ? CupertinoIcons.camera_fill : Icons.camera_alt;
  static IconData save = Platform.isIOS ? CupertinoIcons.floppy_disk : Icons.save;
  static IconData next = Platform.isIOS ? CupertinoIcons.chevron_forward : Icons.chevron_right;
  static IconData takePhoto = Platform.isIOS ? CupertinoIcons.camera : Icons.camera;
  static IconData sound = Platform.isIOS ? CupertinoIcons.volume_up : Icons.volume_up;
  static IconData speed = Platform.isIOS ? CupertinoIcons.speedometer : Icons.speed;
  static IconData delete = Platform.isIOS ? CupertinoIcons.delete_solid : Icons.delete;
  static IconData language = Platform.isIOS ? CupertinoIcons.globe : Icons.language;
  static IconData textSize = Platform.isIOS ? CupertinoIcons.textformat_size : Icons.format_size;
  static IconData cloudUpload = Platform.isIOS ? CupertinoIcons.cloud_upload : Icons.cloud_upload_outlined;
}
