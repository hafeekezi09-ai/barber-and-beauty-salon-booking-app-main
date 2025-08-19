import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  final CollectionReference appointments = FirebaseFirestore.instance
      .collection('appointments');
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? userRole;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await storage.read(key: 'role');
    final email = await storage.read(key: 'email');
    setState(() {
      userRole = role;
      userEmail = email;
    });
  }

  Stream<QuerySnapshot> _getAppointmentsStream() {
    if (userRole == 'super_admin' || userRole == 'SalonManager') {
      return appointments.orderBy('createdAt', descending: true).snapshots();
    } else {
      return appointments
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  Map<DateTime, List> _groupAppointmentsByDay(
    List<QueryDocumentSnapshot> docs,
  ) {
    Map<DateTime, List> events = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('date') && data['date'] is Timestamp) {
        final date = (data['date'] as Timestamp).toDate();
        final day = DateTime(date.year, date.month, date.day);
        events.putIfAbsent(day, () => []);
        events[day]!.add(doc);
      }
    }
    return events;
  }

  Future<void> _addAppointment() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDate == null) return;

    final TextEditingController customerController = TextEditingController();
    final TextEditingController serviceController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Book Appointment"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: serviceController,
                  decoration: const InputDecoration(labelText: 'Service'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final customer = customerController.text.trim();
                  final service = serviceController.text.trim();
                  if (customer.isEmpty || service.isEmpty) return;

                  await appointments.add({
                    'customerName': customer,
                    'service': service,
                    'date': Timestamp.fromDate(selectedDate),
                    'userEmail': userEmail,
                    'createdAt': Timestamp.now(),
                  });

                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments Calendar"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addAppointment),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getAppointmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          final events = _groupAppointmentsByDay(docs);

          List _getEventsForDay(DateTime day) {
            return events[DateTime(day.year, day.month, day.day)] ?? [];
          }

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                eventLoader: _getEventsForDay,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children:
                      _getEventsForDay(_selectedDay ?? _focusedDay).map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final customerName = data['customerName'] ?? 'Unknown';
                        final service = data['service'] ?? 'No service';
                        return ListTile(
                          title: Text(customerName),
                          subtitle: Text(service),
                        );
                      }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
