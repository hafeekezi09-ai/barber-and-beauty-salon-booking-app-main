import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({Key? key}) : super(key: key);

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final CollectionReference services = FirebaseFirestore.instance.collection(
    'services',
  );

  String? userRole;
  bool loadingRole = true;

  @override
  void initState() {
    super.initState();

    print("📍 ServiceManagementScreen loaded"); // Debug

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _fetchUserRole(user.uid);
      } else {
        setState(() {
          userRole = null;
          loadingRole = false;
        });
      }
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      if (doc.exists) {
        final role = doc.data()?['role']?.toString().toLowerCase();
        print("✅ Fetched role: $role"); // Debug
        setState(() {
          userRole = role;
          loadingRole = false;
        });
      } else {
        print("❌ No admin doc found for $uid"); // Debug
        setState(() {
          userRole = null;
          loadingRole = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching role: $e"); // Debug
      setState(() {
        userRole = null;
        loadingRole = false;
      });
    }
  }

  void openServiceForm({DocumentSnapshot? document}) {
    final nameController = TextEditingController(text: document?['name'] ?? '');
    final priceController = TextEditingController(
      text: document?['price']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(document == null ? 'Add Service' : 'Edit Service'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final priceText = priceController.text.trim();

                  if (name.isEmpty || priceText.isEmpty) return;

                  final price = double.tryParse(priceText);
                  if (price == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid price')),
                    );
                    return;
                  }

                  try {
                    if (document == null) {
                      await services.add({
                        'name': name,
                        'price': price,
                        'createdAt': Timestamp.now(),
                      });
                    } else {
                      await services.doc(document.id).update({
                        'name': name,
                        'price': price,
                      });
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save service: $e')),
                    );
                  }
                },
                child: Text(document == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteService(String id) async {
    try {
      await services.doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete service: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ TEMPORARY FOR DEBUGGING — FORCE TRUE
    // final canEdit = userRole == 'super_admin';
    final canEdit = true;

    print("🔍 userRole = $userRole");
    print("🛠️  canEdit = $canEdit");

    return Scaffold(
      appBar: AppBar(title: const Text("Service Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream: services.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final serviceList = snapshot.data!.docs;
          if (serviceList.isEmpty) {
            return const Center(child: Text('No services found.'));
          }

          return ListView.builder(
            itemCount: serviceList.length,
            itemBuilder: (context, index) {
              final doc = serviceList[index];
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text('Price: ₹${doc['price']}'),
                trailing:
                    canEdit
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => openServiceForm(document: doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteService(doc.id),
                            ),
                          ],
                        )
                        // ignore: dead_code
                        : null,
              );
            },
          );
        },
      ),
      floatingActionButton:
          canEdit
              ? FloatingActionButton(
                onPressed: () => openServiceForm(),
                child: const Icon(Icons.add),
              )
              // ignore: dead_code
              : null,
    );
  }
}
