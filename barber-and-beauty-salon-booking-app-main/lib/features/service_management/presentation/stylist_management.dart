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
  final CollectionReference salons = FirebaseFirestore.instance.collection(
    'salons',
  );

  List<String> salonNames = [];

  @override
  void initState() {
    super.initState();
    fetchSalons();
  }

  Future<void> fetchSalons() async {
    final snapshot = await salons.get();
    setState(() {
      salonNames = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  void openAddForm({DocumentSnapshot? document}) {
    final TextEditingController nameController = TextEditingController(
      text: document?.get('name') ?? '',
    );
    final TextEditingController experienceController = TextEditingController(
      text: document?.get('experience')?.toString() ?? '',
    );
    String selectedSalon =
        document?.get('salonName') ??
        (salonNames.isNotEmpty ? salonNames.first : '');

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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSalon.isNotEmpty ? selectedSalon : null,
                  items:
                      salonNames
                          .map(
                            (salon) => DropdownMenuItem(
                              value: salon,
                              child: Text(salon),
                            ),
                          )
                          .toList(),
                  decoration: const InputDecoration(labelText: 'Salon Name'),
                  onChanged: (value) {
                    if (value != null) selectedSalon = value;
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
                  final experienceText = experienceController.text.trim();
                  if (name.isEmpty ||
                      experienceText.isEmpty ||
                      selectedSalon.isEmpty)
                    return;

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
                        'salonName': selectedSalon,
                        'createdAt': Timestamp.now(),
                      });
                    } else {
                      await stylists.doc(document.id).update({
                        'name': name,
                        'experience': experience,
                        'salonName': selectedSalon,
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
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text(
          "Stylist Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[400],
      ),
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

          final docs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data.containsKey('name') &&
                    data.containsKey('experience') &&
                    data.containsKey('salonName');
              }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No stylists found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'No Name';
              final experience = data['experience'] ?? 'N/A';
              final salonName = data['salonName'] ?? 'No Salon';

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
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Experience: $experience yrs\nSalon: $salonName',
                  ),
                  isThreeLine: true,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
