import 'package:flutter/material.dart';
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

  final List<Salon> salons = [
    Salon(
      name: "Glamour Hair Salon",
      type: "Hair salon",
      location: "MG Road, City",
      contact: "9876543210",
      imageUrl: "assets/images/barbor_shop.jpg",
      rating: 4.5,
    ),
    Salon(
      name: "Relax Massage Center",
      type: "Massage",
      location: "Brigade Road, City",
      contact: "9876543211",
      imageUrl: "assets/images/beauty.jpg",
      rating: 4.2,
    ),
    Salon(
      name: "Style Barber Shop",
      type: "Barber",
      location: "Church Street, City",
      contact: "9876543212",
      imageUrl: "assets/images/client.jpg",
      rating: 4.8,
    ),
    Salon(
      name: "Hairstyle Studio",
      type: "Hairstyle",
      location: "Main Street, City",
      contact: "9876543213",
      imageUrl: "assets/images/female_hair.jpg",
      rating: 4.6,
    ),
    Salon(
      name: "Facial & Skin Care",
      type: "Facial",
      location: "Park Avenue, City",
      contact: "9876543214",
      imageUrl: "assets/images/posture.jpg",
      rating: 4.3,
    ),
    Salon(
      name: "Manicure & Pedicure Hub",
      type: "Manicure",
      location: "City Center, City",
      contact: "9876543215",
      imageUrl: "assets/images/smart_hair.jpg",
      rating: 4.7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredSalons =
        salons.where((s) {
          final query = searchTerm.toLowerCase();
          return s.name.toLowerCase().contains(query) ||
              s.type.toLowerCase().contains(query);
        }).toList();

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
                searchTerm = value; // just update the list
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                filteredSalons.isEmpty
                    ? const Center(child: Text("No salons found"))
                    : ListView.builder(
                      itemCount: filteredSalons.length,
                      itemBuilder: (context, index) {
                        final salon = filteredSalons[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Image.asset(
                              salon.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              salon.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(salon.location),
                                Text("Contact: ${salon.contact}"),
                                Row(
                                  children: List.generate(5, (i) {
                                    if (i < salon.rating.round()) {
                                      return const Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 16,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.star_border,
                                        size: 16,
                                      );
                                    }
                                  }),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SalonDetailsPage(salon: salon),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
