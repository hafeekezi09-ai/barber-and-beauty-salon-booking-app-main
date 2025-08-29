import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NearbySalonScreen extends StatelessWidget {
  const NearbySalonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Beauty Salons')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('salons').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final salons = snapshot.data!.docs;
          if (salons.isEmpty)
            return const Center(child: Text('No salons found'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: salons.length,
            itemBuilder: (context, index) {
              final data = salons[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      data['imageUrl'] != null
                          ? CachedNetworkImage(
                            imageUrl: data['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    Container(color: Colors.grey.shade300),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.store),
                          )
                          : const Icon(Icons.store),
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(data['location'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
