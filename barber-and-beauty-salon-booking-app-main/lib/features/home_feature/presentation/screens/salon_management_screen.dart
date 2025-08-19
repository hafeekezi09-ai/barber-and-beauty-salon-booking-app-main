import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SalonManagementScreen extends StatefulWidget {
  const SalonManagementScreen({super.key});

  @override
  State<SalonManagementScreen> createState() => _SalonManagementScreenState();
}

class _SalonManagementScreenState extends State<SalonManagementScreen> {
  final CollectionReference salons = FirebaseFirestore.instance.collection(
    'salons',
  );

  void _openSalonForm({DocumentSnapshot? document}) {
    final TextEditingController nameController = TextEditingController(
      text: document?['name'] ?? '',
    );
    final TextEditingController locationController = TextEditingController(
      text: document?['location'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(document == null ? 'Add Salon' : 'Edit Salon'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Salon Name'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
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
                  final location = locationController.text.trim();

                  if (name.isEmpty || location.isEmpty) return;

                  if (document == null) {
                    // Add new salon (with error handling)
                    try {
                      await salons.add({
                        'name': name,
                        'location': location,
                        'createdAt': Timestamp.now(),
                      });
                    } catch (e) {
                      print("🔥 Error adding salon: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to add salon: $e")),
                      );
                    }
                  } else {
                    // Update existing salon
                    await salons.doc(document.id).update({
                      'name': name,
                      'location': location,
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

  Future<void> _deleteSalon(String id) async {
    await salons.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salon Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSalonForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: salons.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final salonList = snapshot.data!.docs;

          if (salonList.isEmpty) {
            return const Center(child: Text('No salons found.'));
          }

          return ListView.builder(
            itemCount: salonList.length,
            itemBuilder: (context, index) {
              final doc = salonList[index];
              final name = doc['name'];
              final location = doc['location'];

              return ListTile(
                title: Text(name),
                subtitle: Text(location),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openSalonForm(document: doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSalon(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
