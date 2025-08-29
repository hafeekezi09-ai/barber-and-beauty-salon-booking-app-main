import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Profile image notifier
ValueNotifier<Uint8List?> profileImageNotifier = ValueNotifier(null);

/// Profile info notifier: name & location
class ProfileInfo {
  final String name;
  final String location;

  ProfileInfo({required this.name, required this.location});
}

ValueNotifier<ProfileInfo> profileInfoNotifier = ValueNotifier(
  ProfileInfo(name: 'Hafee', location: 'Chennai'),
);
