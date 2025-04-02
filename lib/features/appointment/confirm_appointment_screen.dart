import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/booking_success_screen.dart';

class ConfirmAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String profileImageUrl;
  final String location;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String appointmentMethod;
  final String appointmentPrice;
  final String specialization;

  const ConfirmAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.profileImageUrl,
    required this.location,
    required this.selectedDate,
    required this.selectedTime,
    required this.appointmentMethod,
    required this.appointmentPrice,
    required this.specialization,
  });

  @override
  State<ConfirmAppointmentScreen> createState() =>
      _ConfirmAppointmentScreenState();
}

class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
  bool isLoading = false;

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
        'doctorName': widget.doctorName,
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
        return 'Messaging';
      case 'voice_call':
        return 'Voice Call';
      case 'video_call':
        return 'Video Call';
      case 'in_person':
        return 'In-Person Visit';
      default:
        return 'Appointment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Confirm Appointment",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(widget.profileImageUrl),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr. ${widget.doctorName}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.specialization,
                        style: const TextStyle(color: Colors.grey)),
                    Text(
                      widget.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            // const SizedBox(height: 20),

            // 📅 Date Selection
            const Text(
              "Book Appointment",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 110, 96, 96)),
            ),

            const SizedBox(height: 15),

            // Appointment Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      title: "Date & Hour",
                      value:
                          "${DateFormat('MMMM d, y').format(widget.selectedDate)} | ${widget.selectedTime.format(context)}",
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      title: "Package",
                      value: _getMethodDescription(),
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      title: "Duration",
                      value: "30 minutes",
                    ),
                    // const Divider(height: 24, thickness: 1),
                    // _buildDetailRow(
                    //   title: "Booking for",
                    //   value: "Self",
                    // ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Price Breakdown
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      title: "Amount",
                      value: widget.appointmentPrice,
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      title: "Duration (30 mins)",
                      value: "1 X ${widget.appointmentPrice}",
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      title: "Duration",
                      value: "30 minutes",
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Total Price
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.appointmentPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B479A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B479A),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
