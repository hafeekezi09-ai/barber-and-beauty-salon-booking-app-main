import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateAppointmentScreen extends StatefulWidget {
  final String appointmentId;
  final String currentStatus;

  const UpdateAppointmentScreen({
    super.key,
    required this.appointmentId,
    required this.currentStatus,
  });

  @override
  State<UpdateAppointmentScreen> createState() =>
      _UpdateAppointmentScreenState();
}

class _UpdateAppointmentScreenState extends State<UpdateAppointmentScreen> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.currentStatus;
  }

  Future<void> updateStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({'status': selectedStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment status updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Appointment Status')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Choose new status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            RadioListTile<String>(
              title: const Text('Confirmed'),
              value: 'Confirmed',
              groupValue: selectedStatus,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedStatus = value);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Rejected'),
              value: 'Rejected',
              groupValue: selectedStatus,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedStatus = value);
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: updateStatus,
              child: const Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }
}
