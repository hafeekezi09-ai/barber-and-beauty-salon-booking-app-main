import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Haircut', 'image': 'assets/images/HK2.jpg'},
    {'name': 'Facial', 'image': 'assets/images/facial.jpg'},
    {'name': 'Massage', 'image': 'assets/images/HK1.jpg'},
    {'name': 'Pedicure', 'image': 'assets/images/manicure-mango.jpg'},
    {'name': 'Shaving', 'image': 'assets/images/shaving.jpg'},
    {'name': 'Manicure', 'image': 'assets/images/pedicure.jpg'},
    {'name': 'Hairwash', 'image': 'assets/images/washing-hair.jpg'},
  ];

  CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Categories')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => FullImageScreen(
                        imagePath: category['image']!,
                        title: category['name']!,
                      ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                    child: Image.asset(
                      category['image']!,
                      width: 100, // small width
                      height: 70, // small height
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const FullImageScreen({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: InteractiveViewer(
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
