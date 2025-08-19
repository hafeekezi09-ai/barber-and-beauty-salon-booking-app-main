import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person, size: 30),
              title: const Text(
                "John",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("9876543213"),
              trailing: const Icon(Icons.phone, color: Colors.green),
              onTap: () {
                // optional: call functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
