import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = FlutterSecureStorage();
  String role = '';

  @override
  void initState() {
    super.initState();
    getRole();
  }

  void getRole() async {
    final storedRole = await storage.read(key: 'role');
    setState(() => role = storedRole ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child:
            role == ''
                ? Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome $role",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
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
                    if (role == 'SalonManager') ...[
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Manage My Salon"),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}
