import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final CollectionReference services = FirebaseFirestore.instance.collection(
    'services',
  );
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String? userRole;

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final role = await storage.read(key: 'role');
    setState(() {
      userRole = role;
    });
  }

  void _openServiceForm({DocumentSnapshot? document}) {
    final TextEditingController nameController = TextEditingController(
      text: document?['name'] ?? '',
    );
    final TextEditingController priceController = TextEditingController(
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
                  final price = double.tryParse(priceController.text.trim());

                  if (name.isEmpty || price == null) return;

                  if (document == null) {
                    // Add new service
                    try {
                      await services.add({
                        'name': name,
                        'price': price,
                        'createdAt': Timestamp.now(),
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error adding service: $e")),
                      );
                    }
                  } else {
                    // Update service
                    await services.doc(document.id).update({
                      'name': name,
                      'price': price,
                    });
                  }

                  Navigator.pop(context);
                },
                child: Text(document == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteService(String id) async {
    await services.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final isManager = userRole == 'SalonManager';

    return Scaffold(
      appBar: AppBar(title: const Text("Service Management")),
      floatingActionButton:
          isManager
              ? FloatingActionButton(
                onPressed: () => _openServiceForm(),
                child: const Icon(Icons.add),
              )
              : null,
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
              final name = doc['name'];
              final price = doc['price'];

              return ListTile(
                title: Text(name),
                subtitle: Text("₹ $price"),
                trailing:
                    isManager
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openServiceForm(document: doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteService(doc.id),
                            ),
                          ],
                        )
                        : null,
              );
            },
          );
        },
      ),
    );
  }
}
