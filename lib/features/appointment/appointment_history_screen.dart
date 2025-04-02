// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class AppointmentHistoryScreen extends StatelessWidget {
//   const AppointmentHistoryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final String userId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Appointment History")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('patientId', isEqualTo: userId)
//             .orderBy('dateTime', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No appointment history found"));
//           }

//           var appointments = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: appointments.length,
//             itemBuilder: (context, index) {
//               var appointment = appointments[index];
//               var appointmentId = appointment.id;
//               var doctorId = appointment['doctorId'];
//               var dateTime = (appointment['dateTime'] as Timestamp).toDate();
//               var status = appointment['status'];

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('users').doc(doctorId).get(),
//                 builder: (context, doctorSnapshot) {
//                   if (!doctorSnapshot.hasData) {
//                     return const ListTile(title: Text("Loading doctor..."));
//                   }

//                   var doctorData = doctorSnapshot.data!;
//                   String doctorName = doctorData['fullName'];
//                   String doctorImage = doctorData['profileImageUrl'] ?? "";

//                   return Card(
//                     margin: const EdgeInsets.all(10),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: doctorImage.isNotEmpty
//                             ? NetworkImage(doctorImage)
//                             : const AssetImage('assets/doctor_placeholder.png') as ImageProvider,
//                       ),
//                       title: Text("Dr. $doctorName"),
//                       subtitle: Text(
//                         "${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}\nStatus: $status",
//                       ),
//                       trailing: status == 'pending'
//                           ? Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 TextButton(
//                                   onPressed: () => _rescheduleAppointment(context, appointmentId),
//                                   child: const Text("Reschedule", style: TextStyle(color: Colors.blue)),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => _cancelAppointment(context, appointmentId),
//                                   child: const Text("Cancel", style: TextStyle(color: Colors.red)),
//                                 ),
//                               ],
//                             )
//                           : null,
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _cancelAppointment(BuildContext context, String appointmentId) async {
//     bool confirmCancel = await _showConfirmationDialog(context, "Cancel Appointment", "Are you sure you want to cancel this appointment?");
//     if (confirmCancel) {
//       await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
//         'status': 'cancelled',
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Appointment Cancelled Successfully")),
//       );
//     }
//   }

//   void _rescheduleAppointment(BuildContext context, String appointmentId) async {
//     DateTime? newDate = await _pickDate(context);
//     if (newDate == null) return;

//     TimeOfDay? newTime = await _pickTime(context);
//     if (newTime == null) return;

//     DateTime newDateTime = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);

//     bool confirmReschedule = await _showConfirmationDialog(
//         context, "Reschedule Appointment", "Do you want to reschedule to ${DateFormat('yyyy-MM-dd HH:mm').format(newDateTime)}?");
//     if (confirmReschedule) {
//       await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
//         'dateTime': newDateTime,
//         'status': 'rescheduled',
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Appointment Rescheduled Successfully")),
//       );
//     }
//   }

//   Future<DateTime?> _pickDate(BuildContext context) async {
//     return await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 30)),
//     );
//   }

//   Future<TimeOfDay?> _pickTime(BuildContext context) async {
//     return await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//   }

//   Future<bool> _showConfirmationDialog(BuildContext context, String title, String content) async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(title),
//             content: Text(content),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text("No"),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text("Yes", style: TextStyle(color: Colors.blue)),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }
// }

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
      appBar: AppBar(
        title: const Text("Appointment History"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color.fromARGB(255, 255, 255, 255)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📜 Appointment List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('patientId', isEqualTo: userId)
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No appointment history found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }

              var appointments = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  var appointmentId = appointment.id;
                  var doctorId = appointment['doctorId'];
                  var dateTime =
                      (appointment['dateTime'] as Timestamp).toDate();
                  var status = appointment['status'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(doctorId)
                        .get(),
                    builder: (context, doctorSnapshot) {
                      if (!doctorSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      var doctorData = doctorSnapshot.data!;
                      String doctorName = doctorData['fullName'];
                      String doctorImage = doctorData['profileImageUrl'] ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: doctorImage.isNotEmpty
                                ? NetworkImage(doctorImage)
                                : const AssetImage(
                                        'assets/doctor_placeholder.png')
                                    as ImageProvider,
                          ),
                          title: Text(
                            "Dr. $doctorName",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(dateTime),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(height: 5),
                              _buildStatusBadge(status),
                            ],
                          ),
                          trailing: status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _actionButton(
                                      label: "Reschedule",
                                      color: Colors.blue,
                                      onTap: () => _rescheduleAppointment(
                                          context, appointmentId),
                                    ),
                                    const SizedBox(width: 8),
                                    _actionButton(
                                      label: "Cancel",
                                      color: Colors.red,
                                      onTap: () => _cancelAppointment(
                                          context, appointmentId),
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
        ],
      ),
    );
  }

  // 🎨 Status Badge
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'pending':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange;
        break;
      case 'confirmed':
        bgColor = Colors.green.shade100;
        textColor = Colors.green;
        break;
      case 'cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red;
        break;
      case 'rescheduled':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 📌 Reschedule Appointment
  void _rescheduleAppointment(
      BuildContext context, String appointmentId) async {
    DateTime? newDate = await _pickDate(context);
    if (newDate == null) return;

    TimeOfDay? newTime = await _pickTime(context);
    if (newTime == null) return;

    DateTime newDateTime = DateTime(
        newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);

    bool confirmReschedule = await _showConfirmationDialog(
        context,
        "Reschedule Appointment",
        "Do you want to reschedule to ${DateFormat('yyyy-MM-dd HH:mm').format(newDateTime)}?");
    if (confirmReschedule) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'dateTime': newDateTime,
        'status': 'rescheduled',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment Rescheduled Successfully")),
      );
    }
  }

  // 📌 Cancel Appointment
  void _cancelAppointment(BuildContext context, String appointmentId) async {
    bool confirmCancel = await _showConfirmationDialog(
        context,
        "Cancel Appointment",
        "Are you sure you want to cancel this appointment?");
    if (confirmCancel) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': 'cancelled',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment Cancelled Successfully")),
      );
    }
  }

  // 🎨 Custom Action Button
  Widget _actionButton(
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  // 📅 Pick Date
  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  // ⏰ Pick Time
  Future<TimeOfDay?> _pickTime(BuildContext context) async {
    return await showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  // 🔔 Confirmation Dialog
  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      const Text("Yes", style: TextStyle(color: Colors.blue))),
            ],
          ),
        ) ??
        false;
  }
}
