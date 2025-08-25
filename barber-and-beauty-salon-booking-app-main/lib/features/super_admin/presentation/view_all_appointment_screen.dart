import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAllAppointmentsScreen extends StatelessWidget {
  const ViewAllAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = FirebaseFirestore.instance.collection('appointments');

    return Scaffold(
      appBar: AppBar(title: const Text("All Appointments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointments.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No Appointments"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['customer'] ?? 'No Name';
              final dateTime =
                  data['dateTime'] != null
                      ? (data['dateTime'] as Timestamp).toDate()
                      : null;
              final status = data['status'] ?? 'Pending';

              return ListTile(
                title: Text(name),
                subtitle: Text(
                  'Date: ${dateTime?.toLocal().toString().split('.')[0] ?? "Unknown"}\nStatus: $status',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
