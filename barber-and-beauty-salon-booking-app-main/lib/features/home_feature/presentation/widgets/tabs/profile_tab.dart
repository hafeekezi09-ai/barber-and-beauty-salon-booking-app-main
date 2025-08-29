import 'dart:typed_data';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String name = "Hk";
  String email = "hafeekezi00@gmail.com";
  String mobileNumber = "9325687415";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? name;
      email = prefs.getString('email') ?? email;
      mobileNumber = prefs.getString('mobile') ?? mobileNumber;
    });
  }

  Uint8List? _getCurrentImage() {
    return profileImageNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _getCurrentImage();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          imageBytes != null
                              ? MemoryImage(imageBytes)
                              : const AssetImage(
                                    'assets/images/profile-image.jpg',
                                  )
                                  as ImageProvider,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      mobileNumber,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                        if (updated == true) _loadProfile();
                      },
                      child: const Text("Edit Profile"),
                    ),
                    const SizedBox(height: 10),
                    // Book Appointment button removed as per your request
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
