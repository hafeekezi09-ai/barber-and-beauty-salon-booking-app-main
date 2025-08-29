import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileImageWidget extends StatefulWidget {
  const UserProfileImageWidget({super.key});

  @override
  State<UserProfileImageWidget> createState() => _UserProfileImageWidgetState();
}

class _UserProfileImageWidgetState extends State<UserProfileImageWidget> {
  File? _imageFile;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!kIsWeb) {
      final path = prefs.getString('profile_image');
      if (path != null && File(path).existsSync()) _imageFile = File(path);
    } else {
      final base64 = prefs.getString('profile_image_web');
      if (base64 != null) _webImageBytes = base64Decode(base64);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundImage:
          _webImageBytes != null
              ? MemoryImage(_webImageBytes!)
              : _imageFile != null
              ? FileImage(_imageFile!)
              : const AssetImage('assets/images/profile-image.jpg'),
    );
  }
}
