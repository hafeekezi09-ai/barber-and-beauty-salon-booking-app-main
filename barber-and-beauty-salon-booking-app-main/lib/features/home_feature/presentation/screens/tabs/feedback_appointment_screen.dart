import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/assets.gen.dart';

class FeedbackAppointmentScreen extends StatefulWidget {
  final String shopName;
  final String serviceName;
  final String imagePath;
  final String address;

  const FeedbackAppointmentScreen({
    super.key,
    required this.shopName,
    required this.serviceName,
    required this.imagePath,
    required this.address,
  });

  @override
  State<FeedbackAppointmentScreen> createState() =>
      _FeedbackAppointmentScreenState();
}

class _FeedbackAppointmentScreenState extends State<FeedbackAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Feedback variables
  int _rating = 0;
  String? _feedbackType;
  Map<String, dynamic>? _selectedService; // selected service object
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmittingFeedback = false;

  // Appointment variables
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Map<String, dynamic>? _appointmentService;
  String? _selectedStylistId;
  String? _selectedSalonId;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  bool _isBookingAppointment = false;

  List<Map<String, dynamic>> _availableServices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Automatically fill user name if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _customerNameController.text = user.displayName ?? '';
    }

    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .where('salonName', isEqualTo: widget.shopName)
              .get();

      final services =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      if (!mounted) return;
      setState(() => _availableServices = services);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch services: $e")));
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _notesController.dispose();
    _customerNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Feedback submission
  Future<void> _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedService == null) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a rating.")));
      return;
    }

    setState(() => _isSubmittingFeedback = true);

    try {
      await FirebaseFirestore.instance.collection('shop_feedback').add({
        'shopName': widget.shopName,
        'serviceName': _selectedService!['name'],
        'price': _selectedService!['price'],
        'rating': _rating,
        'feedbackType': _feedbackType ?? _selectedService!['name'],
        'comment': _feedbackController.text.trim(),
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _feedbackController.clear();
      setState(() {
        _rating = 0;
        _selectedService = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Feedback submitted!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _isSubmittingFeedback = false);
    }
  }

  // Appointment booking
  Future<void> _bookAppointment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        _appointmentService == null ||
        _selectedStylistId == null)
      return;

    final customerName = _customerNameController.text.trim();
    if (customerName.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
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
      await FirebaseFirestore.instance.collection('appointments').add({
        'salonId': _selectedSalonId,
        'salonName': widget.shopName, // Salon name added
        'serviceName': _appointmentService!['name'],
        'price': _appointmentService!['price'],
        'appointmentTime': appointmentDateTime,
        'notes': _notesController.text.trim(),
        'customer': customerName,
        'userId': user.uid,
        'status': 'pending',
        'stylistId': _selectedStylistId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _notesController.clear();
      _customerNameController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _selectedStylistId = null;
        _appointmentService = null;
        _selectedSalonId = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Appointment booked!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _isBookingAppointment = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Feedback"), Tab(text: "Appointment")],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      (widget.imagePath.isNotEmpty &&
                              widget.imagePath != "string")
                          ? Image.network(
                            widget.imagePath,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) => Image.asset(
                                  Assets.images.hairStyle.path,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                          )
                          : Image.asset(
                            Assets.images.hairStyle.path,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.shopName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.serviceName,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(widget.address),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildFeedbackTab(),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildAppointmentTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rate your experience:", style: TextStyle(fontSize: 16)),
        Row(
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
              ),
              onPressed: () {
                if (!mounted) return;
                setState(() => _rating = i + 1);
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        DropdownButton<Map<String, dynamic>>(
          value: _selectedService,
          hint: const Text("Select Service"),
          isExpanded: true,
          items:
              _availableServices
                  .map(
                    (service) => DropdownMenuItem<Map<String, dynamic>>(
                      value: service,
                      child: Text(service['name']),
                    ),
                  )
                  .toList(),
          onChanged: (val) {
            if (!mounted) return;
            setState(() {
              _selectedService = val;
              _feedbackType = val?['name'];
            });
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _feedbackController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Write your feedback...",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton(
            onPressed: _isSubmittingFeedback ? null : _submitFeedback,
            child:
                _isSubmittingFeedback
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Feedback"),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Book an Appointment:", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        TextField(
          controller: _customerNameController,
          decoration: const InputDecoration(
            labelText: "Your Name",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<Map<String, dynamic>>(
          value: _appointmentService,
          hint: const Text("Select Service"),
          isExpanded: true,
          items:
              _availableServices
                  .map(
                    (service) => DropdownMenuItem<Map<String, dynamic>>(
                      value: service,
                      child: Text("${service['name']} - ₹${service['price']}"),
                    ),
                  )
                  .toList(),
          onChanged: (val) {
            if (!mounted) return;
            setState(() => _appointmentService = val);
          },
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('stylists')
                  .where('salonName', isEqualTo: widget.shopName)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final stylists = snapshot.data!.docs;
            if (stylists.isEmpty) return const Text("No stylists available.");

            return DropdownButton<String>(
              hint: const Text("Select Stylist"),
              value:
                  stylists.any((doc) => doc.id == _selectedStylistId)
                      ? _selectedStylistId
                      : null,
              isExpanded: true,
              items:
                  stylists
                      .map(
                        (doc) => DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                            "${doc['name'] ?? 'Unknown'} (${doc['experience'] ?? ''} yrs)",
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (!mounted) return;
                setState(() => _selectedStylistId = val);
              },
            );
          },
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
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: "Any notes for your appointment...",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton(
            onPressed: _isBookingAppointment ? null : _bookAppointment,
            child:
                _isBookingAppointment
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Book Appointment"),
          ),
        ),
      ],
    );
  }
}
