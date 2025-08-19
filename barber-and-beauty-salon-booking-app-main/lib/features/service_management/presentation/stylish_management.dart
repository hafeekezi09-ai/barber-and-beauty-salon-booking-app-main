import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StylistManagementScreen extends StatefulWidget {
  const StylistManagementScreen({super.key});

  @override
  State<StylistManagementScreen> createState() =>
      _StylistManagementScreenState();
}

class _StylistManagementScreenState extends State<StylistManagementScreen> {
  final CollectionReference stylists = FirebaseFirestore.instance.collection(
    'stylists',
  );
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  void _openStylistForm({DocumentSnapshot? document}) {
    final TextEditingController nameController = TextEditingController(
      text: document != null ? document['name'] : '',
    );
    final TextEditingController specialtyController = TextEditingController(
      text: document != null ? document['specialty'] : '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(document == null ? 'Add Stylist' : 'Edit Stylist'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Stylist Name'),
                ),
                TextField(
                  controller: specialtyController,
                  decoration: const InputDecoration(labelText: 'Specialty'),
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
                  final specialty = specialtyController.text.trim();
                  if (name.isEmpty || specialty.isEmpty) return;

                  if (document == null) {
                    await stylists.add({
                      'name': name,
                      'specialty': specialty,
                      'createdAt': Timestamp.now(),
                    });
                  } else {
                    await stylists.doc(document.id).update({
                      'name': name,
                      'specialty': specialty,
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

  Future<void> _deleteStylist(String id) async {
    await stylists.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stylist Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: _openStylistForm,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stylists.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text('No stylists found.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(doc['specialty']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openStylistForm(document: doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteStylist(doc.id),
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
