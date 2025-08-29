import 'package:flutter/material.dart';

class SpecialOffersScreen extends StatelessWidget {
  const SpecialOffersScreen({super.key});

  final List<Map<String, String>> offers = const [
    {
      'title': '50% OFF Haircut',
      'description': 'Get half off your first haircut!',
    },
    {
      'title': 'Free Facial',
      'description': 'Book a massage and get a facial free!',
    },
    {
      'title': '20% OFF Hair Dye',
      'description': 'Limited time offer on premium hair dye services.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Special Offers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.red),
              title: Text(
                offer['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(offer['description']!),
            ),
          );
        },
      ),
    );
  }
}
