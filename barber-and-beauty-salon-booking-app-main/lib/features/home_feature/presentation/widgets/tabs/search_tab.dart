import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'salon_model.dart';
import 'salon_details_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController searchController = TextEditingController();
  String searchTerm = "";

  final CollectionReference salonsCollection = FirebaseFirestore.instance
      .collection('salons');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search salon, massage, barber...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchTerm = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  salonsCollection
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No salons found"));
                }

                // Map Firestore docs to Salon model
                final salons =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Salon(
                        name: data['name'] ?? '',
                        type: data['type'] ?? '',
                        location: data['location'] ?? '',
                        contact: data['contact'] ?? '',
                        imageUrl:
                            data['imageUrl'] ?? 'assets/images/default.jpg',
                        rating: (data['rating'] ?? 0).toDouble(),
                      );
                    }).toList();

                // Filter by search term
                final filteredSalons =
                    salons.where((s) {
                      return s.name.toLowerCase().contains(searchTerm) ||
                          s.type.toLowerCase().contains(searchTerm);
                    }).toList();

                if (filteredSalons.isEmpty) {
                  return const Center(child: Text("No salons found"));
                }

                return ListView.builder(
                  itemCount: filteredSalons.length,
                  itemBuilder: (context, index) {
                    final salon = filteredSalons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading:
                            salon.imageUrl.isNotEmpty
                                ? Image.network(
                                  salon.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(Icons.error),
                                )
                                : const Icon(Icons.store),
                        title: Text(
                          salon.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(salon.location),
                            if (salon.contact.isNotEmpty)
                              Text("Contact: ${salon.contact}"),
                            Row(
                              children: List.generate(5, (i) {
                                return i < salon.rating.round()
                                    ? const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    )
                                    : const Icon(Icons.star_border, size: 16);
                              }),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SalonDetailsPage(salon: salon),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
