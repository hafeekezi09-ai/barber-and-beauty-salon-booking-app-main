import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  // Step
  int currentStep = 0;

  // Step 1
  String? selectedService;
  String? selectedStylist;

  // Step 2
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Dummy data
  final List<String> services = [
    'Haircut',
    'Massage',
    'Facial',
    'Manicure',
    'Pedicure',
  ];

  final List<String> stylists = ['John', 'Emma', 'Sophia', 'David'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep == 0 &&
              (selectedService == null || selectedStylist == null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select service and stylist'),
              ),
            );
            return;
          }
          if (currentStep == 1 &&
              (selectedDate == null || selectedTime == null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select date and time')),
            );
            return;
          }
          if (currentStep < 2) {
            setState(() => currentStep += 1);
          } else {
            _showConfirmationDialog();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          Step(
            title: const Text('Select Service & Stylist'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Service:'),
                Wrap(
                  spacing: 8,
                  children:
                      services
                          .map(
                            (s) => ChoiceChip(
                              label: Text(s),
                              selected: selectedService == s,
                              onSelected: (val) {
                                setState(() {
                                  selectedService = val ? s : null;
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
                const Text('Select Stylist:'),
                Wrap(
                  spacing: 8,
                  children:
                      stylists
                          .map(
                            (s) => ChoiceChip(
                              label: Text(s),
                              selected: selectedStylist == s,
                              onSelected: (val) {
                                setState(() {
                                  selectedStylist = val ? s : null;
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
            isActive: currentStep == 0,
          ),
          Step(
            title: const Text('Select Date & Time'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Date:'),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Pick a Date'
                        : DateFormat('dd MMM yyyy').format(selectedDate!),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Select Time:'),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                  child: Text(
                    selectedTime == null
                        ? 'Pick Time'
                        : selectedTime!.format(context),
                  ),
                ),
              ],
            ),
            isActive: currentStep == 1,
          ),
          Step(
            title: const Text('Confirm Appointment'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service: $selectedService'),
                Text('Stylist: $selectedStylist'),
                Text(
                  'Date: ${selectedDate != null ? DateFormat('dd MMM yyyy').format(selectedDate!) : ''}',
                ),
                Text(
                  'Time: ${selectedTime != null ? selectedTime!.format(context) : ''}',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Status: Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            isActive: currentStep == 2,
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Appointment'),
            content: Text(
              'Service: $selectedService\nStylist: $selectedStylist\nDate: ${selectedDate != null ? DateFormat('dd MMM yyyy').format(selectedDate!) : ''}\nTime: ${selectedTime != null ? selectedTime!.format(context) : ''}\nStatus: Pending',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Save latest appointment with status to SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  final appointment = {
                    'name': selectedStylist ?? '',
                    'service': selectedService ?? '',
                    'dateTime':
                        selectedDate != null && selectedTime != null
                            ? '${DateFormat('dd MMM yyyy').format(selectedDate!)} . ${selectedTime!.format(context)}'
                            : '',
                    'price': '170.00', // Default price
                    'image': 'assets/images/massage.jpg',
                    'status': 'Pending', // Initial status
                  };
                  await prefs.setString(
                    'latest_appointment',
                    jsonEncode(appointment),
                  );

                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return success to ProfileTab
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }
}
