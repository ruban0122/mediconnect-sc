import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/booking_success_screen.dart';

class ConfirmAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String appointmentMethod;
  final String appointmentPrice;

  const ConfirmAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.selectedDate,
    required this.selectedTime,
    required this.appointmentMethod,
    required this.appointmentPrice,
  });

  @override
  State<ConfirmAppointmentScreen> createState() =>
      _ConfirmAppointmentScreenState();
}

class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
  bool isLoading = false;
  String doctorName = '';
  String doctorSpecialty = '';

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();
      if (doctorDoc.exists) {
        setState(() {
          doctorName = doctorDoc['fullName'] ?? "Unknown Doctor";
          doctorSpecialty = doctorDoc['specialization'] ?? "General";
        });
      }
    } catch (e) {
      print("Error fetching doctor details: $e");
    }
  }

  Future<void> _confirmBooking() async {
    setState(() {
      isLoading = true;
    });

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      String userId = auth.currentUser!.uid;
      DateTime appointmentDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        widget.selectedTime.hour,
        widget.selectedTime.minute,
      );

      String appointmentId = "$userId-${DateTime.now().millisecondsSinceEpoch}";
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .set({
        'patientId': userId,
        'doctorId': widget.doctorId,
        'dateTime': appointmentDateTime.toUtc(),
        'status': 'pending',
        'method': widget.appointmentMethod,
        'price': widget.appointmentPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BookingSuccessScreen(),
        ),
      );
    } catch (e) {
      print("Error booking appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book appointment. Try again.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getMethodDescription() {
    switch (widget.appointmentMethod) {
      case 'messaging':
        return 'Messaging Appointment';
      case 'voice_call':
        return 'Voice Call Appointment';
      case 'video_call':
        return 'Video Call Appointment';
      case 'in_person':
        return 'In-Person Visit';
      default:
        return 'Appointment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info
            Text("Doctor: $doctorName",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Specialty: $doctorSpecialty",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            
            // Appointment Details Card
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEE, MMM d, y').format(widget.selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          widget.selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // Appointment Method
                    Row(
                      children: [
                        const Icon(Icons.medical_services, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          _getMethodDescription(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          widget.appointmentPrice,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Total Price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(widget.appointmentPrice, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Confirm Booking",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}