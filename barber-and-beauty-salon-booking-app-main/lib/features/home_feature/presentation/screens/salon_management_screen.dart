import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalonManagementScreen extends StatefulWidget {
  const SalonManagementScreen({Key? key}) : super(key: key);

  @override
  State<SalonManagementScreen> createState() => _SalonManagementScreenState();
}

class _SalonManagementScreenState extends State<SalonManagementScreen> {
  final CollectionReference salons = FirebaseFirestore.instance.collection(
    'salons',
  );

  String? userRole;
  bool loadingRole = true;

  @override
  void initState() {
    super.initState();
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
    setState(() => loadingRole = true);

    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final role =
            data != null && data.containsKey('role')
                ? data['role'].toString().toLowerCase()
                : null;

        setState(() {
          userRole = role;
          loadingRole = false;
        });
      } else {
        setState(() {
          userRole = null;
          loadingRole = false;
        });
      }
    } catch (e) {
      setState(() {
        userRole = null;
        loadingRole = false;
      });
    }
  }

  void openSalonForm({DocumentSnapshot? document}) {
    final nameController = TextEditingController(text: document?['name'] ?? '');
    final locationController = TextEditingController(
      text: document?['location'] ?? '',
    );
    final imageUrlController = TextEditingController(
      text: document?['imageUrl'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              document == null ? 'Add Salon' : 'Edit Salon',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: 'Salon Name'),
                  ),
                  TextField(
                    controller: locationController,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  TextField(
                    controller: imageUrlController,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final location = locationController.text.trim();
                  final imageUrl = imageUrlController.text.trim();

                  if (name.isEmpty || location.isEmpty || imageUrl.isEmpty)
                    return;

                  try {
                    if (document == null) {
                      await salons.add({
                        'name': name,
                        'location': location,
                        'imageUrl': imageUrl,
                        'createdAt': Timestamp.now(),
                      });
                    } else {
                      await salons.doc(document.id).update({
                        'name': name,
                        'location': location,
                        'imageUrl': imageUrl,
                      });
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Failed: $e")));
                  }
                },
                child: Text(
                  document == null ? 'Add' : 'Update',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteSalon(String id) async {
    try {
      await salons.doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final canEdit = userRole == "super_admin";

    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        title: const Text(
          "Salon Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: salons.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final salonList = snapshot.data!.docs;
          if (salonList.isEmpty) {
            return const Center(
              child: Text(
                'No salons found.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: salonList.length,
            itemBuilder: (context, index) {
              final doc = salonList[index];
              final name = doc['name'] ?? '';
              final location = doc['location'] ?? '';
              final imageUrl = doc['imageUrl'] ?? '';

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  leading:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(Icons.error),
                          )
                          : const Icon(Icons.store),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    location,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing:
                      canEdit
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => openSalonForm(document: doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteSalon(doc.id),
                              ),
                            ],
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          canEdit
              ? FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () => openSalonForm(),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
