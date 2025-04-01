import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/booking_success_screen.dart';

class ConfirmAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const ConfirmAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.selectedDate,
    required this.selectedTime,
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
          doctorSpecialty = doctorDoc['specialty'] ?? "General";
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

      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': userId,
        'doctorId': widget.doctorId,
        'dateTime': appointmentDateTime.toUtc(),
        'status': 'pending',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Doctor: $doctorName",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Specialty: $doctorSpecialty",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),

            Text(
              "Date: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Time: ${widget.selectedTime.format(context)}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),

            // ✅ Confirmation Button
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _confirmBooking,
                      child: const Text("Confirm Booking"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
