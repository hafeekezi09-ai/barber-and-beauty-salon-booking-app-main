import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String role;

  AdminDashboardScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $role",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // SuperAdmin buttons
            if (role == 'SuperAdmin') ...[
              ElevatedButton(
                onPressed: () {},
                child: Text("Manage All Salons"),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text("Manage All Admins"),
              ),
            ],

            // SalonManager buttons
            if (role == 'SalonManager') ...[
              ElevatedButton(onPressed: () {}, child: Text("Manage My Salon")),
            ],
          ],
        ),
      ),
    );
  }
}
