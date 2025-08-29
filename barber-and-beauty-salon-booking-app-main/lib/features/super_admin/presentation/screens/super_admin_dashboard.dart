import 'package:barber_and_beauty_salon_booking_app/features/super_admin/presentation/screens/appointment_calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/salon_management_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/service_management/service_management_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/service_management/presentation/stylist_management.dart';
import 'package:barber_and_beauty_salon_booking_app/features/super_admin/super_admin_feedback_screen.dart';

class SuperAdminDashboard extends StatelessWidget {
  final String role;

  const SuperAdminDashboard({Key? key, required this.role}) : super(key: key);

  Widget _buildTile(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text(
          "Super Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[400],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (role.toLowerCase() == 'super_admin') ...[
            _buildTile(
              context,
              "Salon Management",
              const SalonManagementScreen(),
            ),
            _buildTile(
              context,
              "Service Management",
              const ServiceManagementScreen(),
            ),
            _buildTile(
              context,
              "Stylist Management",
              const StylistManagementScreen(),
            ),
            _buildTile(
              context,
              "Appointment Management",
              const AppointmentCalendarScreen(),
            ),
            _buildTile(
              context,
              "View User Feedback",
              const SuperAdminFeedbackScreen(),
            ),
          ],
        ],
      ),
    );
  }
}
