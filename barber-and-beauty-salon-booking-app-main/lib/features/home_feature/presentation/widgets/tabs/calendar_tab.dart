import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  bool currentUserIsManager = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;
      _checkIfManager(currentUser.uid);
    }
  }

  Future<void> _checkIfManager(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('admins').doc(uid).get();
    if (doc.exists) {
      setState(() {
        currentUserIsManager = doc.data()?['role'] == 'SalonManager';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Center(
        child: Text("Please log in to see your appointments."),
      );
    }

    final appointmentStream =
        FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', whereIn: [currentUserId])
            .orderBy('appointmentTime', descending: true)
            .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: appointmentStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No appointments found.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final docId = docs[index].id;

            final service = data['serviceName']?.toString() ?? 'Unknown';
            final shop = data['shopName']?.toString() ?? 'Unknown';
            final notes = data['notes']?.toString() ?? '';
            final customer = data['customer']?.toString() ?? 'Unknown';
            String status = data['status']?.toString() ?? 'pending';

            final timestamp = data['appointmentTime'];
            final formattedDate =
                timestamp is Timestamp
                    ? DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(timestamp.toDate())
                    : 'Unknown date';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('$service at $shop'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: $customer'),
                    Text('Date & Time: $formattedDate'),
                    if (notes.isNotEmpty) Text('Notes: $notes'),
                  ],
                ),
                trailing:
                    currentUserIsManager
                        ? DropdownButton<String>(
                          value: status,
                          items:
                              ['pending', 'confirmed', 'rejected']
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(docId)
                                  .update({'status': newStatus});
                            }
                          },
                        )
                        : Text('Status: $status'),
              ),
            );
          },
        );
      },
    );
  }
}
