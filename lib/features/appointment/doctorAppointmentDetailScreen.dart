// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mediconnect/notification_service.dart';

// class DoctorAppointmentDetailScreen extends StatefulWidget {
//   final DocumentSnapshot appointment;

//   const DoctorAppointmentDetailScreen({
//     super.key,
//     required this.appointment,
//   });

//   @override
//   State<DoctorAppointmentDetailScreen> createState() =>
//       _DoctorAppointmentDetailScreenState();
// }

// class _DoctorAppointmentDetailScreenState
//     extends State<DoctorAppointmentDetailScreen> {
//   final TextEditingController _notesController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateTime = (widget.appointment['dateTime'] as Timestamp).toDate();
//     final status = widget.appointment['status'];
//     final method = widget.appointment['method'] ?? 'appointment';
//     final price = widget.appointment['price'] ?? 'Not specified';

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "My Appointments",
//           style: TextStyle(
//             color: Color(0xFF2B479A),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.appointment['patientId'])
//             .get(),
//         builder: (context, patientSnapshot) {
//           if (!patientSnapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final patientData = patientSnapshot.data!;
//           final patientName = patientData['fullName'] ?? 'Unknown Patient';
//           final patientEmail = patientData['email'] ?? 'No email';
//           final patientImage = patientData['profileImageUrl'];

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Patient Info
//                 _buildPatientHeader(patientName, patientEmail, patientImage),
//                 const SizedBox(height: 24),

//                 _buildSectionTitle("Appointment Information"),
//                 const SizedBox(height: 20),
//                 _buildInfoCard([
//                   _buildInfoTile(Icons.calendar_today, "Date",
//                       DateFormat('MMMM dd, yyyy').format(dateTime)),
//                   _buildInfoTile(Icons.access_time, "Time",
//                       DateFormat('hh:mm a').format(dateTime)),
//                   _buildInfoTile(_getMethodIcon(method), "Type",
//                       method.replaceAll('_', ' ').toUpperCase()),
//                   _buildInfoTile(Icons.attach_money, "Fee", price.toString()),
//                 ]),

//                 const SizedBox(height: 24),

//                 // Status
//                 Center(child: _buildStatusBadge(status)),

//                 const SizedBox(height: 24),

//                 // Action Buttons
//                 if (status == 'pending') _buildActionButtons(),

//                 const SizedBox(height: 24),

//                 // _buildSectionTitle("Doctor Notes"),
//                 // const SizedBox(height: 8),
//                 // TextField(
//                 //   controller: _notesController,
//                 //   maxLines: 4,
//                 //   decoration: InputDecoration(
//                 //     hintText: 'Add notes about this appointment...',
//                 //     border: OutlineInputBorder(
//                 //         borderRadius: BorderRadius.circular(12)),
//                 //   ),
//                 // ),
//                 // const SizedBox(height: 16),
//                 // Align(
//                 //   alignment: Alignment.centerRight,
//                 //   child: ElevatedButton(
//                 //     onPressed: _saveNotes,
//                 //     style: ElevatedButton.styleFrom(
//                 //       padding: const EdgeInsets.symmetric(
//                 //           horizontal: 24, vertical: 12),
//                 //       shape: RoundedRectangleBorder(
//                 //           borderRadius: BorderRadius.circular(8)),
//                 //     ),
//                 //     child: const Text("Save Notes"),
//                 //   ),
//                 // ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(title,
//         style: const TextStyle(
//             fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey));
//   }

//   Widget _buildPatientHeader(String name, String email, String? imageUrl) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 35,
//           backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//           child: imageUrl == null ? const Icon(Icons.person, size: 36) : null,
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(name,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               Text(email, style: const TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoCard(List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.2),
//             blurRadius: 10,
//             spreadRadius: 2,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: children,
//       ),
//     );
//   }

//   Widget _buildInfoTile(IconData icon, String title, String subtitle) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(icon, color: const Color(0xFF2B479A)),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey)),
//               Text(subtitle,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.w500)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status) {
//     Color bgColor;
//     Color textColor;

//     switch (status) {
//       case 'pending':
//         bgColor = Colors.orange.shade100;
//         textColor = Colors.orange;
//         break;
//       case 'confirmed':
//         bgColor = Colors.green.shade100;
//         textColor = Colors.green;
//         break;
//       case 'cancelled':
//         bgColor = Colors.red.shade100;
//         textColor = Colors.red;
//         break;
//       case 'completed':
//         bgColor = Colors.blue.shade100;
//         textColor = Colors.blue;
//         break;
//       default:
//         bgColor = Colors.grey.shade200;
//         textColor = Colors.black;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _actionButton({
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return TextButton(
//       onPressed: onTap,
//       style: TextButton.styleFrom(
//         backgroundColor: color.withOpacity(0.1),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       child: Text(label,
//           style: TextStyle(
//               color: color, fontSize: 16, fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _actionButton(
//           label: "Confirm",
//           color: Colors.green,
//           onTap: () => _updateStatus('confirmed'),
//         ),
//         const SizedBox(width: 30),
//         _actionButton(
//           label: "Cancel",
//           color: Colors.red,
//           onTap: () => _updateStatus('cancelled'),
//         ),
//       ],
//     );
//   }

//   IconData _getMethodIcon(String method) {
//     switch (method) {
//       case 'messaging':
//         return Icons.message;
//       case 'voice_call':
//         return Icons.call;
//       case 'video_call':
//         return Icons.videocam;
//       case 'in_person':
//         return Icons.person;
//       default:
//         return Icons.calendar_today;
//     }
//   }

//   Future<void> _updateStatus(String newStatus) async {
//     setState(() => _isLoading = true);
//     try {
//       await FirebaseFirestore.instance
//           .collection('appointments')
//           .doc(widget.appointment.id)
//           .update({
//         'status': newStatus,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       await NotificationService.sendNotificationToUser(
//         userId: widget.appointment['patientId'],
//         title: 'Appointment Status Updated',
//         body: 'Your appointment has been $newStatus',
//         data: {
//           'type': 'appointment_status',
//           'appointmentId': widget.appointment.id,
//           'status': newStatus,
//         },
//       );

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Appointment marked as $newStatus")),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update: $e")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _saveNotes() async {
//     setState(() => _isLoading = true);
//     try {
//       await FirebaseFirestore.instance
//           .collection('appointments')
//           .doc(widget.appointment.id)
//           .update({
//         'doctorNotes': _notesController.text,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Notes saved successfully")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to save notes: $e")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/videoCalling/video_call_screen.dart';
import 'package:mediconnect/notification_service.dart';

class DoctorAppointmentDetailScreen extends StatefulWidget {
  final DocumentSnapshot appointment;

  const DoctorAppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<DoctorAppointmentDetailScreen> createState() =>
      _DoctorAppointmentDetailScreenState();
}

class _DoctorAppointmentDetailScreenState
    extends State<DoctorAppointmentDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = (widget.appointment['dateTime'] as Timestamp).toDate();
    final status = widget.appointment['status'];
    final method = widget.appointment['method'] ?? 'appointment';
    final price = widget.appointment['price'] ?? 'Not specified';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Appointments",
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.appointment['patientId'])
            .get(),
        builder: (context, patientSnapshot) {
          if (!patientSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final patientData = patientSnapshot.data!;
          final patientName = patientData['fullName'] ?? 'Unknown Patient';
          final patientEmail = patientData['email'] ?? 'No email';
          final patientImage = patientData['profileImageUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientHeader(patientName, patientEmail, patientImage),
                const SizedBox(height: 24),

                _buildSectionTitle("Appointment Information"),
                const SizedBox(height: 20),
                _buildInfoCard([
                  _buildInfoTile(Icons.calendar_today, "Date",
                      DateFormat('MMMM dd, yyyy').format(dateTime)),
                  _buildInfoTile(Icons.access_time, "Time",
                      DateFormat('hh:mm a').format(dateTime)),
                  _buildInfoTile(_getMethodIcon(method), "Type",
                      method.replaceAll('_', ' ').toUpperCase()),
                  _buildInfoTile(Icons.attach_money, "Fee", price.toString()),
                ]),

                const SizedBox(height: 24),

                Center(child: _buildStatusBadge(status)),

                const SizedBox(height: 24),

                if (status == 'pending') _buildActionButtons(),

                if ((status == 'confirmed' || status == 'in_progress') &&
                    method == 'video_call')
                  Center(child: _buildJoinCallButton()),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey));
  }

  Widget _buildPatientHeader(String name, String email, String? imageUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null ? const Icon(Icons.person, size: 36) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2B479A)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

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
      case 'completed':
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

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _actionButton(
          label: "Confirm",
          color: Colors.green,
          onTap: () => _updateStatus('confirmed'),
        ),
        const SizedBox(width: 30),
        _actionButton(
          label: "Cancel",
          color: Colors.red,
          onTap: () => _updateStatus('cancelled'),
        ),
      ],
    );
  }

  Widget _buildJoinCallButton() {
    return ElevatedButton.icon(
      onPressed: _navigateToVideoCall,
      icon: const Icon(Icons.videocam),
      label: const Text("Join Video Call"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2B479A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          channelName: widget.appointment.id,
          userRole: 'doctor',
          appointmentId: widget.appointment.id,
        ),
      ),
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'messaging':
        return Icons.message;
      case 'voice_call':
        return Icons.call;
      case 'video_call':
        return Icons.videocam;
      case 'in_person':
        return Icons.person;
      default:
        return Icons.calendar_today;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment.id)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await NotificationService.sendNotificationToUser(
        userId: widget.appointment['patientId'],
        title: 'Appointment Status Updated',
        body: 'Your appointment has been $newStatus',
        data: {
          'type': 'appointment_status',
          'appointmentId': widget.appointment.id,
          'status': newStatus,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment marked as $newStatus")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNotes() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment.id)
          .update({
        'doctorNotes': _notesController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notes saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save notes: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
