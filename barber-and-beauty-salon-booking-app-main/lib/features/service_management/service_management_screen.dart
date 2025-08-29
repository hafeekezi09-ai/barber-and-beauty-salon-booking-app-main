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
    try {
      final doc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      if (doc.exists) {
        final role = doc.data()?['role']?.toString().toLowerCase();
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

  void openServiceForm({DocumentSnapshot? document}) async {
    final nameController = TextEditingController(text: document?['name'] ?? '');
    final priceController = TextEditingController(
      text: document?['price']?.toString() ?? '',
    );

    // Fetch all salon names for dropdown
    final salonSnapshot = await salons.orderBy('createdAt').get();
    final salonNames =
        salonSnapshot.docs.map((doc) => doc['name'].toString()).toList();

    String? selectedSalon =
        document != null &&
                (document.data() as Map<String, dynamic>).containsKey(
                  'salonName',
                )
            ? document['salonName']
            : null;

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
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedSalon,
                  decoration: const InputDecoration(
                    labelText: 'Select Salon',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      salonNames
                          .map(
                            (salon) => DropdownMenuItem<String>(
                              value: salon,
                              child: Text(salon),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    selectedSalon = val;
                  },
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

                  if (name.isEmpty ||
                      priceText.isEmpty ||
                      selectedSalon == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All fields are required')),
                    );
                    return;
                  }

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
                        'salonName': selectedSalon,
                        'createdAt': Timestamp.now(),
                      });
                    } else {
                      await services.doc(document.id).update({
                        'name': name,
                        'price': price,
                        'salonName': selectedSalon,
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

    final canEdit = userRole == 'super_admin';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Service Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
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
            padding: const EdgeInsets.all(12),
            itemCount: serviceList.length,
            itemBuilder: (context, index) {
              final doc = serviceList[index];
              final data = doc.data() as Map<String, dynamic>;
              final salonName =
                  data.containsKey('salonName') ? data['salonName'] : 'Unknown';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Price: ₹${data['price']} - Salon: $salonName',
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
                                onPressed: () => openServiceForm(document: doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteService(doc.id),
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
                onPressed: () => openServiceForm(),
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
