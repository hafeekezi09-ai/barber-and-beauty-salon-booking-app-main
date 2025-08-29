import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/update_appointment_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/super_admin/presentation/view_all_appointment_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
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
          "Manager Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Salon Manager!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              label: const Text(
                "View All Appointments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green[700],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ViewAllAppointmentsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('appointments')
                        .orderBy('appointmentTime', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No appointments found.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final stylistId = data['stylistId'] ?? '';
                      final salonId = data['salonId'] ?? '';
                      final salonName =
                          data['salonName'] ??
                          salonNamesMap[salonId] ??
                          'Not Assigned';
                      final status = data['status'] ?? 'Pending';
                      final customerName = data['customer'] ?? 'Customer';
                      final serviceName = data['serviceName'] ?? '';
                      final notes = data['notes'] ?? '';
                      final appointmentTime =
                          (data['appointmentTime'] as Timestamp).toDate();

                      final stylistName =
                          stylistNamesMap[stylistId] ?? 'Not Assigned';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$salonName • $customerName • $serviceName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Stylist: $stylistName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Status: $status',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (notes.isNotEmpty)
                                    Text(
                                      'Notes: $notes',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  Text(
                                    '${appointmentTime.day}/${appointmentTime.month}/${appointmentTime.year} ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => UpdateAppointmentScreen(
                                          appointmentId: doc.id,
                                          currentStatus: status,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
