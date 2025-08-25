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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image: fits width, no cropping
            Container(
              width: 500,
              height: 500, // adjust height as needed
              child: FittedBox(
                fit: BoxFit.contain, // prevents cropping
                child: Image.asset('assets/images/posture.jpg'),
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon Name
                  Text(
                    salon.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Salon Type
                  Text(
                    salon.type,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Text(
                    "Location: ${salon.location}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),

                  // Contact
                  Text(
                    "Contact: ${salon.contact}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  // Rating stars
                  Row(
                    children: List.generate(5, (i) {
                      if (i < salon.rating.round()) {
                        return const Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 39, 165, 100),
                          size: 20,
                        );
                      } else {
                        return const Icon(Icons.star_border, size: 20);
                      }
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Services & Stylists
                  const Text(
                    "Services & Stylists:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• Haircut\n• Massage\n• Hairstyle\n• Facial\n• Manicure",
                    style: TextStyle(fontSize: 16),
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
