import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/assets.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/fonts.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/colors.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/dimens.dart';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_elevated_button.dart';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_light_text.dart';

import 'update_appointment_screen.dart'; // your status update screen

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  Map<String, String>? appointment;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadLatestAppointment();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLatestAppointment() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentJson = prefs.getString('latest_appointment');
    if (appointmentJson != null) {
      setState(() {
        appointment = Map<String, String>.from(jsonDecode(appointmentJson));
      });
      _updateStatus();
    }
  }

  void _updateStatus() async {
    if (appointment == null || appointment!['dateTime'] == null) return;

    // Skip auto-update if manually rejected
    if (appointment!['status'] == 'Rejected') return;

    try {
      final dateParts = appointment!['dateTime']!.split(' . ');
      final date = DateFormat('dd MMM yyyy').parse(dateParts[0]);
      final timeParts = dateParts[1].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].split(' ')[0]);
      final isPM = timeParts[1].contains('PM');
      if (isPM && hour < 12) hour += 12;

      final appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      final now = DateTime.now();
      String status =
          now.isAfter(appointmentDateTime) ? 'Completed' : 'Confirmed';

      if (appointment!['status'] != status) {
        setState(() {
          appointment!['status'] = status;
        });

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('latest_appointment', jsonEncode(appointment));
      }
    } catch (_) {
      setState(() {
        appointment!['status'] = 'Confirmed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointments")),
      body:
          appointment == null
              ? Center(
                child: Text(
                  'No recent appointments',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : ListView(
                padding: EdgeInsets.all(Dimens.largePadding),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(Dimens.corners),
                    ),
                    padding: EdgeInsets.all(Dimens.largePadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimens.corners),
                            color: AppColors.primaryColor,
                          ),
                          padding: EdgeInsets.only(top: Dimens.padding),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimens.corners),
                            child: Image.asset(
                              appointment!['image'] ?? Assets.images.user1.path,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        SizedBox(width: Dimens.largePadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    appointment!['name'] ?? '',
                                    style: TextStyle(
                                      fontFamily: FontFamily.aksharMedium,
                                      fontSize: 16,
                                    ),
                                  ),
                                  AppLightText(appointment!['service'] ?? ''),
                                ],
                              ),
                              SizedBox(height: Dimens.largePadding),
                              Text(
                                appointment!['dateTime'] ?? '',
                                style: TextStyle(
                                  fontFamily: FontFamily.aksharMedium,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: Dimens.smallPadding),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '\$${appointment!['price'] ?? '0.00'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: FontFamily.aksharMedium,
                                        ),
                                      ),
                                      Text(
                                        '/Person',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  AppElevatedButton(
                                    onPressed: () async {
                                      final updatedAppointment =
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      UpdateAppointmentScreen(
                                                        appointment: Map<
                                                          String,
                                                          String
                                                        >.from(appointment!),
                                                      ),
                                            ),
                                          );

                                      if (updatedAppointment != null) {
                                        setState(() {
                                          appointment =
                                              Map<String, String>.from(
                                                updatedAppointment,
                                              );
                                        });

                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        prefs.setString(
                                          'latest_appointment',
                                          jsonEncode(appointment),
                                        );
                                      }
                                    },
                                    title:
                                        appointment!['status'] ?? 'Confirmed',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
