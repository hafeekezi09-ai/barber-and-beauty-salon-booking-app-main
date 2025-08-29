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

  Map<String, String> stylistNamesMap = {};
  Map<String, String> salonNamesMap = {};

  String _appointmentService = 'haircut';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedStylistId;
  String? _selectedSalonId;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  bool _isBookingAppointment = false;

  final List<String> _services = ['haircut', 'massage', 'manicure', 'facial'];

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _fetchAllStylists();
    _fetchAllSalons();
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      setState(() {
        userRole = doc.exists ? doc['role'] ?? 'user' : 'user';
      });
    }
  }

  Future<void> _fetchAllStylists() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('stylists').get();
    final map = <String, String>{};
    for (var doc in snapshot.docs) {
      map[doc.id] = doc['name'] ?? 'Unknown';
    }
    setState(() => stylistNamesMap = map);
  }

  Future<void> _fetchAllSalons() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('salons').get();
    final map = <String, String>{};
    for (var doc in snapshot.docs) {
      map[doc.id] = doc['name'] ?? 'Unknown';
    }
    setState(() => salonNamesMap = map);
  }

  Stream<QuerySnapshot> _getAppointmentsStream() {
    Query baseQuery = appointments.orderBy('appointmentTime');
    if (userRole == 'super_admin' || userRole == 'SalonManager') {
      return baseQuery.snapshots();
    } else {
      return baseQuery.where('userId', isEqualTo: uid).snapshots();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _bookAppointment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final customerName = _customerNameController.text.trim();
    if (customerName.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedStylistId == null ||
        _selectedSalonId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isBookingAppointment = true);

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      // Add salonName to fix "Not Assigned" issue
      final salonName = salonNamesMap[_selectedSalonId!] ?? 'Salon';

      await appointments.add({
        'serviceName': _appointmentService.toLowerCase(),
        'appointmentTime': appointmentDateTime,
        'notes': _notesController.text.trim(),
        'customer': customerName,
        'userId': user.uid,
        'status': 'pending',
        'stylistId': _selectedStylistId,
        'salonId': _selectedSalonId,
        'salonName': salonName, // <-- added
        'timestamp': FieldValue.serverTimestamp(),
      });

      _notesController.clear();
      _customerNameController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _selectedStylistId = null;
        _selectedSalonId = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Appointment booked!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isBookingAppointment = false);
    }
  }

  void _showBookingDialog() {
    _customerNameController.clear();
    _notesController.clear();
    setState(() {
      _appointmentService = 'haircut';
      _selectedDate = null;
      _selectedTime = null;
      _selectedSalonId = null;
      _selectedStylistId = null;
    });

    _showEditDialog(null);
  }

  void _showEditDialog(DocumentSnapshot? doc) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _customerNameController.text = data['customer'] ?? '';
      final service = (data['serviceName'] ?? 'haircut').toLowerCase();
      _appointmentService =
          _services.contains(service) ? service : _services.first;
      _notesController.text = data['notes'] ?? '';
      _selectedStylistId = data['stylistId'];
      _selectedSalonId = data['salonId'];

      final appointmentTime = (data['appointmentTime'] as Timestamp).toDate();
      _selectedDate = appointmentTime;
      _selectedTime = TimeOfDay.fromDateTime(appointmentTime);
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(doc == null ? "Book Appointment" : "Edit Appointment"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: "Customer Name",
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value:
                        _services.contains(_appointmentService)
                            ? _appointmentService
                            : null,
                    isExpanded: true,
                    hint: const Text("Select Service"),
                    items:
                        _services
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(_capitalize(s)),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(() => _appointmentService = val!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedSalonId,
                    hint: const Text("Select Salon"),
                    isExpanded: true,
                    items:
                        salonNamesMap.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedSalonId = val),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedStylistId,
                    hint: const Text("Select Stylist"),
                    isExpanded: true,
                    items:
                        stylistNamesMap.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(() => _selectedStylistId = val),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickDate,
                          child: Text(
                            _selectedDate == null
                                ? "Select Date"
                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickTime,
                          child: Text(
                            _selectedTime == null
                                ? "Select Time"
                                : _selectedTime!.format(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: "Notes"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    _isBookingAppointment ? null : () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed:
                    _isBookingAppointment
                        ? null
                        : () async {
                          setState(() => _isBookingAppointment = true);

                          final newDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          );

                          try {
                            if (doc == null) {
                              await _bookAppointment();
                            } else {
                              final salonName =
                                  salonNamesMap[_selectedSalonId!] ?? 'Salon';
                              await appointments.doc(doc.id).update({
                                'customer': _customerNameController.text.trim(),
                                'serviceName': _appointmentService,
                                'appointmentTime': newDateTime,
                                'notes': _notesController.text.trim(),
                                'stylistId': _selectedStylistId,
                                'salonId': _selectedSalonId,
                                'salonName': salonName,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Appointment updated!"),
                                ),
                              );
                            }

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          } finally {
                            setState(() => _isBookingAppointment = false);
                          }
                        },
                child:
                    _isBookingAppointment
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(doc == null ? "Book" : "Update"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Appointment Calendar"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

              final customer = data['customer'] ?? 'Customer';
              final service = _capitalize(data['serviceName'] ?? '');
              final stylistId = data['stylistId'] ?? '';
              final salonId = data['salonId'] ?? '';
              final status = data['status'] ?? 'Pending';
              final notes = data['notes'] ?? '';
              final appointmentTime =
                  (data['appointmentTime'] as Timestamp).toDate();

              final stylistName = stylistNamesMap[stylistId] ?? 'Not Assigned';
              // Use salonName if exists, fallback to mapping
              final salonName =
                  data['salonName'] ?? salonNamesMap[salonId] ?? 'Not Assigned';

              return Card(
                color: Colors.lightGreen[200],
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  title: Text('$customer • $service'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Salon: $salonName'),
                      Text('Stylist: $stylistName'),
                      Text('Status: $status'),
                      if (notes.isNotEmpty) Text('Notes: $notes'),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(appointmentTime),
                      ),
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
                                onPressed: () => _showEditDialog(doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await appointments.doc(doc.id).delete();
                                },
                              ),
                            ],
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          userRole == 'super_admin'
              ? FloatingActionButton(
                backgroundColor: Colors.green[700],
                onPressed: _showBookingDialog,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}
