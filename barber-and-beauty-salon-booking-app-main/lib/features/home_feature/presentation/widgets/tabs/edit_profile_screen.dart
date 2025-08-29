import 'dart:io';
import 'dart:convert';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/profile_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  File? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString('name') ?? 'Hafee';
      locationController.text = prefs.getString('location') ?? 'Chennai';
      emailController.text = prefs.getString('email') ?? '';
      mobileController.text = prefs.getString('mobile') ?? '';

      if (!kIsWeb) {
        final path = prefs.getString('profile_image');
        if (path != null && File(path).existsSync()) _imageFile = File(path);
      } else {
        final base64 = prefs.getString('profile_image_web');
        if (base64 != null) _webImage = base64Decode(base64);
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (!kIsWeb) {
        _imageFile = File(picked.path);
      } else {
        _webImage = await picked.readAsBytes();
      }
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', nameController.text);
    await prefs.setString('location', locationController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('mobile', mobileController.text);

    if (!kIsWeb && _imageFile != null) {
      await prefs.setString('profile_image', _imageFile!.path);
      profileImageNotifier.value = _imageFile!.readAsBytesSync();
    } else if (kIsWeb && _webImage != null) {
      await prefs.setString('profile_image_web', base64Encode(_webImage!));
      profileImageNotifier.value = _webImage;
    }

    // Update profile info notifier
    profileInfoNotifier.value = ProfileInfo(
      name: nameController.text,
      location: locationController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        _webImage != null
            ? MemoryImage(_webImage!)
            : _imageFile != null
            ? FileImage(_imageFile!)
            : const AssetImage('assets/images/profile-image.jpg')
                as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(radius: 50, backgroundImage: imageProvider),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: 'Mobile'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _saveProfile, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
