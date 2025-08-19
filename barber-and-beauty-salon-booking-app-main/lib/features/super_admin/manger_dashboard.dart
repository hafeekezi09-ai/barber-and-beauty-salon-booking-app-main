import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/calendar_tab.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/update_appointment_screen.dart';
import 'package:flutter/material.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Salon Manager!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text("View All Appointments"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarTab()),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text("Update Appointment Status"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => const UpdateAppointmentScreen(
                          appointment: {
                            'name': 'John Doe',
                            'service': 'Haircut',
                            'dateTime': '19 Aug 2025 . 02:00 PM',
                            'price': '20.00',
                            'status': 'Pending',
                            'image': 'assets/images/john.jpg',
                          },
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text("View Appointment Details"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
