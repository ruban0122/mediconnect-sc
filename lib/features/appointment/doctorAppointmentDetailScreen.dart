import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  final String patientId;
  final DateTime dateTime;
 // final String reason;
  final String status;

  const DoctorAppointmentDetailScreen({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.dateTime,
   // required this.reason,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Appointment Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(patientId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var patientData = snapshot.data!;
          String patientName = patientData['fullName'];
          String patientEmail = patientData['email'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Patient: $patientName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Email: $patientEmail"),
                const SizedBox(height: 16),
                Text("Appointment Date: ${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}"),
                const SizedBox(height: 16),
                // Text("Reason: $reason"),
                // const SizedBox(height: 32),
                if (status == 'pending') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateAppointmentStatus(context, appointmentId, 'approved'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Approve"),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateAppointmentStatus(context, appointmentId, 'rejected'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Reject"),
                      ),
                    ],
                  ),
                ] else
                  Center(child: Text("Status: ${status.toUpperCase()}", style: const TextStyle(fontSize: 16))),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateAppointmentStatus(BuildContext context, String appointmentId, String newStatus) async {
    await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
      'status': newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Appointment marked as $newStatus")),
    );

    Navigator.pop(context);
  }
}
