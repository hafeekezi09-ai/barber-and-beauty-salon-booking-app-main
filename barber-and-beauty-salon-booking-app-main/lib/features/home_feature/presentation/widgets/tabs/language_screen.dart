import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Language"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("English"),
            onTap: () {
              Navigator.pop(context, "English");
            },
          ),
          ListTile(
            title: const Text("Tamil"),
            onTap: () {
              Navigator.pop(context, "Tamil");
            },
          ),
          ListTile(
            title: const Text("Hindi"),
            onTap: () {
              Navigator.pop(context, "Hindi");
            },
          ),
        ],
      ),
    );
  }
}
