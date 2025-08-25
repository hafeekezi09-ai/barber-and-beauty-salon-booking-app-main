import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StylistManagementScreen extends StatefulWidget {
  const StylistManagementScreen({super.key});

  @override
  StylistManagementScreenState createState() => StylistManagementScreenState();
}

class StylistManagementScreenState extends State<StylistManagementScreen> {
  final CollectionReference stylists = FirebaseFirestore.instance.collection(
    'stylists',
  );

  void openAddForm({DocumentSnapshot? document}) {
    final TextEditingController nameController = TextEditingController(
      text: document?.get('name') ?? '',
    );
    final TextEditingController experienceController = TextEditingController(
      text: document?.get('experience')?.toString() ?? '',
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
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: experienceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Experience (years)',
                  ),
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
                  final experienceText = experienceController.text.trim();
                  if (name.isEmpty || experienceText.isEmpty) return;

                  final experience = int.tryParse(experienceText);
                  if (experience == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter valid experience')),
                    );
                    return;
                  }

                  try {
                    if (document == null) {
                      await stylists.add({
                        'name': name,
                        'experience': experience,
                        'createdAt': Timestamp.now(),
                      });
                    } else {
                      await stylists.doc(document.id).update({
                        'name': name,
                        'experience': experience,
                      });
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                },
                child: Text(document == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteStylist(String id) async {
    try {
      await stylists.doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stylist Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stylists.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final validDocs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data.containsKey('name') &&
                    data.containsKey('experience');
              }).toList();

          if (validDocs.isEmpty) {
            return const Center(child: Text('No stylists found.'));
          }

          return ListView.builder(
            itemCount: validDocs.length,
            itemBuilder: (context, index) {
              final doc = validDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'No Name';
              final experience = data['experience'] ?? 'N/A';

              return ListTile(
                title: Text(name),
                subtitle: Text('Experience: $experience yrs'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => openAddForm(document: doc),
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
