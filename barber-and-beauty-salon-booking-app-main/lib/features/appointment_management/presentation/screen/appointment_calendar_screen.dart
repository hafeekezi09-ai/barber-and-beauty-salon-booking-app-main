import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  final CollectionReference appointments = FirebaseFirestore.instance
      .collection('appointments');

  String userRole = '';
  String? uid;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      setState(() {
        userRole = doc.exists ? doc['role'] ?? '' : 'user';
      });
    }
  }

  Stream<QuerySnapshot> _getAppointmentsStream() {
    Query baseQuery = appointments.orderBy('dateTime');
    if (userRole == 'super_admin' || userRole == 'SalonManager') {
      return baseQuery.snapshots();
    } else {
      return baseQuery.where('uid', isEqualTo: uid).snapshots();
    }
  }

  void _openAppointmentDialog({DocumentSnapshot? doc}) {
    final TextEditingController customerController = TextEditingController(
      text: doc != null ? doc['customer'] ?? '' : '',
    );
    final TextEditingController serviceController = TextEditingController(
      text: doc != null ? doc['service'] ?? '' : '',
    );
    final TextEditingController stylistController = TextEditingController(
      text: doc != null ? doc['stylist'] ?? '' : '',
    );

    DateTime? selectedDateTime =
        doc != null ? (doc['dateTime'] as Timestamp).toDate() : null;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Text(
                    doc == null ? 'Add Appointment' : 'Edit Appointment',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: customerController,
                          decoration: const InputDecoration(
                            labelText: 'Customer',
                          ),
                        ),
                        TextField(
                          controller: serviceController,
                          decoration: const InputDecoration(
                            labelText: 'Service',
                          ),
                        ),
                        TextField(
                          controller: stylistController,
                          decoration: const InputDecoration(
                            labelText: 'Stylist',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedDateTime != null
                                    ? DateFormat(
                                      'dd MMM yyyy, hh:mm a',
                                    ).format(selectedDateTime!)
                                    : 'Select Date & Time',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      selectedDateTime ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (pickedDate != null) {
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    setStateDialog(() {
                                      selectedDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final customer = customerController.text.trim();
                        final service = serviceController.text.trim();
                        final stylist = stylistController.text.trim();

                        if (customer.isEmpty ||
                            service.isEmpty ||
                            stylist.isEmpty ||
                            selectedDateTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        try {
                          if (doc == null) {
                            await appointments.add({
                              'customer': customer,
                              'service': service,
                              'stylist': stylist,
                              'status': 'Pending',
                              'dateTime': Timestamp.fromDate(selectedDateTime!),
                              'createdAt': Timestamp.now(),
                              'uid': uid,
                            });
                          } else {
                            await appointments.doc(doc.id).update({
                              'customer': customer,
                              'service': service,
                              'stylist': stylist,
                              'dateTime': Timestamp.fromDate(selectedDateTime!),
                            });
                          }
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: Text(doc == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _updateStatus(String appointmentId, String newStatus) async {
    await appointments.doc(appointmentId).update({'status': newStatus});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Status updated')));
  }

  Future<void> _deleteAppointment(String id) async {
    await appointments.doc(id).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Appointment deleted')));
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("All Appointments")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getAppointmentsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading appointments'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text('No appointments available.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final customer = data['customer'] ?? '';
                final service = data['service'] ?? '';
                final stylist = data['stylist'] ?? '';
                final status = data['status'] ?? 'Pending';
                final dateTime = (data['dateTime'] as Timestamp).toDate();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('$customer • $service'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stylist: $stylist'),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(dateTime),
                        ),
                        Text('Status: $status'),
                      ],
                    ),
                    trailing:
                        userRole == 'super_admin'
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed:
                                      () => _openAppointmentDialog(doc: doc),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteAppointment(doc.id),
                                ),
                              ],
                            )
                            : userRole == 'SalonManager'
                            ? PopupMenuButton<String>(
                              onSelected:
                                  (value) => _updateStatus(doc.id, value),
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'Confirmed',
                                      child: Text('Confirm'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Rejected',
                                      child: Text('Reject'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Completed',
                                      child: Text('Complete'),
                                    ),
                                  ],
                              icon: const Icon(Icons.edit_calendar),
                            )
                            : null,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton:
          userRole == 'super_admin'
              ? FloatingActionButton(
                onPressed: () => _openAppointmentDialog(),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
