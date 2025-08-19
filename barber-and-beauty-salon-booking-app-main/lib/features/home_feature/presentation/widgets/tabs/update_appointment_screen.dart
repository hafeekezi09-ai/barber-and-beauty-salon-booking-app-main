import 'package:flutter/material.dart';

class UpdateAppointmentScreen extends StatelessWidget {
  final Map<String, String> appointment;

  const UpdateAppointmentScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    String currentStatus = appointment['status'] ?? 'Pending';

    return Scaffold(
      appBar: AppBar(title: const Text("Update Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update status for ${appointment['name']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(n"Confirmed"),
              leading: Radio<String>(
                value: "Confirmed",
                groupValue: currentStatus,
                onChanged: (value) {
                  appointment['status'] = value!;
                  Navigator.pop(context, appointment);
                },
              ),
            ),
            ListTile(
              title: const Text("Rejected"),
              leading: Radio<String>(
                value: "Rejected",
                groupValue: currentStatus,
                onChanged: (value) {
                  appointment['status'] = value!;
                  Navigator.pop(context, appointment);
                },
              ),
            ),
            ListTile(
              title: const Text("Rejected"),
              leading: Radio<String>(
                value: "Pending",
                groupValue: currentStatus,
                onChanged: (value) {
                  appointment['status'] = value!;
                  Navigator.pop(context, appointment);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
