import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/salon_model.dart';
import 'package:flutter/material.dart';

import 'salon_details_screen.dart';

class SalonBrowseScreen extends StatelessWidget {
  final List<Salon> salons;

  const SalonBrowseScreen({super.key, required this.salons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Salons"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: salons.length,
        itemBuilder: (context, index) {
          final salon = salons[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Image.asset(
                salon.imageUrl,
                width: 60,
                fit: BoxFit.cover,
              ),
              title: Text(
                salon.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(salon.location),
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
      ),
    );
  }
}
