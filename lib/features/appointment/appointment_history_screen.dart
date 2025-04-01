import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Appointment History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
           // .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointment history found"));
          }

          var appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              var appointmentId = appointment.id;
              var doctorId = appointment['doctorId'];
              var dateTime = (appointment['dateTime'] as Timestamp).toDate();
              var status = appointment['status'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(doctorId).get(),
                builder: (context, doctorSnapshot) {
                  if (!doctorSnapshot.hasData) {
                    return const ListTile(title: Text("Loading doctor..."));
                  }

                  var doctorData = doctorSnapshot.data!;
                  String doctorName = doctorData['fullName'];
                  String doctorImage = doctorData['profileImageUrl'] ?? "";

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: doctorImage.isNotEmpty
                            ? NetworkImage(doctorImage)
                            : const AssetImage('assets/doctor_placeholder.png') as ImageProvider,
                      ),
                      title: Text("Dr. $doctorName"),
                      subtitle: Text(
                        "${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}\nStatus: $status",
                      ),
                      trailing: status == 'pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => _rescheduleAppointment(context, appointmentId),
                                  child: const Text("Reschedule", style: TextStyle(color: Colors.blue)),
                                ),
                                TextButton(
                                  onPressed: () => _cancelAppointment(context, appointmentId),
                                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _cancelAppointment(BuildContext context, String appointmentId) async {
    bool confirmCancel = await _showConfirmationDialog(context, "Cancel Appointment", "Are you sure you want to cancel this appointment?");
    if (confirmCancel) {
      await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment Cancelled Successfully")),
      );
    }
  }

  void _rescheduleAppointment(BuildContext context, String appointmentId) async {
    DateTime? newDate = await _pickDate(context);
    if (newDate == null) return;

    TimeOfDay? newTime = await _pickTime(context);
    if (newTime == null) return;

    DateTime newDateTime = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);

    bool confirmReschedule = await _showConfirmationDialog(
        context, "Reschedule Appointment", "Do you want to reschedule to ${DateFormat('yyyy-MM-dd HH:mm').format(newDateTime)}?");
    if (confirmReschedule) {
      await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
        'dateTime': newDateTime,
        'status': 'rescheduled',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment Rescheduled Successfully")),
      );
    }
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
