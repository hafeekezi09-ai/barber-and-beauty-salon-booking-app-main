import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Not logged in"));
    }

    final Stream<QuerySnapshot<Map<String, dynamic>>> appointmentStream =
        FirebaseFirestore.instance
            .collection('appointments')
            .where('uid', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: appointmentStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Firestore snapshot error: ${snapshot.error}');
          return const Center(child: Text('Something went wrong.'));
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

            final customer = data['customer'] as String? ?? 'Unknown';
            final service = data['service'] as String? ?? 'Unknown';
            final stylist = data['stylist'] as String? ?? 'Unknown';
            final status = data['status'] as String? ?? 'Pending';

            final timestamp = data['dateTime'] as Timestamp?;
            final dateTime = timestamp?.toDate();
            final formattedDate =
                dateTime != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(dateTime)
                    : 'Unknown date';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('$customer • $service'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stylist: $stylist'),
                    Text('Time: $formattedDate'),
                    Text('Status: $status'),
                  ],
                ),
                trailing: const Icon(Icons.calendar_today),
              ),
            );
          },
        );
      },
    );
  }
}
