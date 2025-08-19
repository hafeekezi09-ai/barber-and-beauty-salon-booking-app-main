import 'package:flutter/material.dart';
import 'salon_model.dart';

class SalonDetailsPage extends StatelessWidget {
  final Salon salon;

  const SalonDetailsPage({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(salon.name)),
      body: SingleChildScrollView(
        // <-- add parentheses here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              salon.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(salon.type),
                  Text("Location: ${salon.location}"),
                  Text("Contact: ${salon.contact}"),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      if (i < salon.rating.round()) {
                        return const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 20,
                        );
                      } else {
                        return const Icon(Icons.star_border, size: 20);
                      }
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Services & Stylists:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• Haircut\n• Massage\n• Hairstyle\n• Facial\n• Manicure",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
