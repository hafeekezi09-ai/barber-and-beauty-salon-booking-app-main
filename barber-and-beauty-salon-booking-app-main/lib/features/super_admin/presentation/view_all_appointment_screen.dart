import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewAllAppointmentsScreen extends StatefulWidget {
  const ViewAllAppointmentsScreen({super.key});

  @override
  State<ViewAllAppointmentsScreen> createState() =>
      _ViewAllAppointmentsScreenState();
}

class _ViewAllAppointmentsScreenState extends State<ViewAllAppointmentsScreen> {
  Map<String, String> stylistNamesMap = {};
  Map<String, String> salonNamesMap = {};

  @override
  void initState() {
    super.initState();
    _fetchAllStylists();
    _fetchAllSalons();
  }

  Future<void> _fetchAllStylists() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('stylists').get();
    final Map<String, String> map = {};
    for (var doc in snapshot.docs) {
      map[doc.id] = doc['name'] ?? 'Unknown Stylist';
    }
    setState(() => stylistNamesMap = map);
  }

  Future<void> _fetchAllSalons() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('salons').get();
    final Map<String, String> map = {};
    for (var doc in snapshot.docs) {
      map[doc.id] = doc['name'] ?? 'Unknown Salon';
    }
    setState(() => salonNamesMap = map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text(
          "All Appointments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('appointments')
                .orderBy('appointmentTime')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading appointments",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs;
          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                "No appointments found",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              final stylistId = data['stylistId'] ?? '';
              final salonId = data['salonId'] ?? '';
              final salonName =
                  data['salonName'] ?? salonNamesMap[salonId] ?? 'Not Assigned';
              final status = data['status'] ?? 'Pending';
              final appointmentTime =
                  (data['appointmentTime'] as Timestamp).toDate();
              final customerName = data['customer'] ?? 'Customer';
              final serviceName = data['serviceName'] ?? '';
              final notes = data['notes'] ?? '';

              final stylistName = stylistNamesMap[stylistId] ?? 'Not Assigned';

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$salonName • $customerName • $serviceName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stylist: $stylistName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Status: $status',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(appointmentTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (notes.isNotEmpty)
                      Text(
                        'Notes: $notes',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
