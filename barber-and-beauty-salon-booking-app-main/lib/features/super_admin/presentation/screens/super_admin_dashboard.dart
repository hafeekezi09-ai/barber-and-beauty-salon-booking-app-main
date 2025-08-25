import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/salon_management_screen.dart';
import 'package:flutter/material.dart';

import 'package:barber_and_beauty_salon_booking_app/features/service_management/service_management_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/service_management/presentation/stylist_management.dart';
import 'package:barber_and_beauty_salon_booking_app/features/appointment_management/presentation/screen/appointment_calendar_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/super_admin/super_admin_feedback_screen.dart';

class SuperAdminDashboard extends StatelessWidget {
  final String role;

  const SuperAdminDashboard({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Super Admin Dashboard")),
      body: ListView(
        children: [
          if (role.toLowerCase() == 'super_admin') ...[
            ListTile(
              title: const Text("Salon Management"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SalonManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Service Management"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ServiceManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Stylist Management"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StylistManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Appointment Management"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppointmentCalendarScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("View User Feedback"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuperAdminFeedbackScreen(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
