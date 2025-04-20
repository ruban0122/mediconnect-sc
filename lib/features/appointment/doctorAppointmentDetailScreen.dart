import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/videoCalling/chatting/chat_screen.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance; // Add this line
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  bool canJoinCall(DateTime appointmentTime) {
    final now = DateTime.now();
    final startWindow = appointmentTime.subtract(const Duration(minutes: 10));
    final endWindow = appointmentTime.add(const Duration(minutes: 40));
    return now.isAfter(startWindow) && now.isBefore(endWindow);
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
                  Center(child: _buildJoinCallButton(canJoinCall(dateTime))),
                if ((status == 'confirmed' || status == 'in_progress') &&
                    method == 'messaging')
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            appointmentId: widget.appointment.id,
                            otherUserId: widget.appointment['patientId'],
                            otherUserName: patientName,
                            otherUserImageUrl: patientImage,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text("Open Chat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B479A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
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

  Widget _buildJoinCallButton(bool enabled) {
    return ElevatedButton.icon(
      onPressed: enabled ? _navigateToVideoCall : null,
      icon: const Icon(Icons.videocam),
      label: Text(
        enabled ? "Join Video Call" : "Not Available Yet",
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? const Color(0xFF2B479A) : Colors.grey,
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

  //Problem-Solving 3 - Q2 - Software Construction
  Future<void> _updateStatus(String newStatus) async {
    // Debug output header
    debugPrint('\n=== STARTING STATUS UPDATE CHECKS ===');
    debugPrint('Current Status: ${widget.appointment['status']}');
    debugPrint('Requested New Status: $newStatus');

    // PRE-CONDITION ASSERTIONS
    debugPrint('\n--- Checking Pre-Conditions ---');
    assert(widget.appointment.exists, "Appointment document must exist");
    debugPrint('✓ Document exists check passed');

    assert(
        widget.appointment.id.isNotEmpty, "Appointment ID must not be empty");
    debugPrint('✓ ID not empty check passed');

    assert(['confirmed', 'cancelled'].contains(newStatus),
        "Invalid status value - can only confirm or cancel");
    debugPrint('✓ Valid status transition check passed');

    assert(widget.appointment['status'] == 'pending',
        "Can only update status from 'pending'");
    debugPrint('✓ Current status is pending check passed');

    assert(_auth.currentUser?.uid == widget.appointment['doctorId'],
        "Only assigned doctor can update status");
    debugPrint('✓ Doctor authorization check passed');

    // CLASS INVARIANTS
    debugPrint('\n--- Checking Class Invariants ---');
    assert(_auth.currentUser != null, "Doctor must be authenticated");
    debugPrint('✓ Doctor authenticated check passed');

    assert(!_isLoading, "Operation already in progress");
    debugPrint('✓ No duplicate operation check passed');

    setState(() => _isLoading = true);
    debugPrint('\n--- Starting Status Update Process ---');

    try {
      // PROCESSING INVARIANTS
      final originalStatus = widget.appointment['status'];
      assert(originalStatus == 'pending', "Original status must be pending");
      debugPrint('✓ Original status verification passed');

      // Perform the update
      debugPrint('Updating Firestore document...');
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment.id)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // POST-CONDITION ASSERTIONS
      debugPrint('\n--- Verifying Post-Conditions ---');
      debugPrint('Fetching updated document...');
      final updatedDoc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment.id)
          .get();

      assert(updatedDoc.exists, "Appointment document should still exist");
      debugPrint('✓ Document existence check passed');

      assert(updatedDoc['status'] == newStatus,
          "Status should be updated to $newStatus");
      debugPrint('✓ Status update verification passed');

      assert(
          updatedDoc['updatedAt'] != null, "updatedAt timestamp should be set");
      debugPrint('✓ Timestamp update verification passed');

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
      debugPrint('\n=== STATUS UPDATE COMPLETED SUCCESSFULLY ===');
    } catch (e) {
      // ERROR HANDLING INVARIANTS
      debugPrint('\n!!! ERROR DURING STATUS UPDATE !!!');
      debugPrint('Error: $e');
      assert(false, "Status update failed: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    } finally {
      // CLEANUP INVARIANTS
      setState(() => _isLoading = false);
      assert(!_isLoading, "Loading state must be reset after operation");
      debugPrint('✓ Loading state reset verification passed');
    }
  }

  //Problem-Solving 3 - Q3 - Software Construction
//   Future<void> _updateStatus(String newStatus) async {
//   // Debug output header
//   debugPrint('\n=== STARTING STATUS UPDATE CHECKS ===');
//   debugPrint('Current Status: ${widget.appointment['status']}');
//   debugPrint('Requested New Status: $newStatus');

//   // PRE-CONDITION CHECKS
//   debugPrint('\n--- Checking Pre-Conditions ---');
//   require(widget.appointment.exists, "Appointment document must exist");
//   debugPrint('✓ Document exists check passed');

//   require(widget.appointment.id.isNotEmpty, "Appointment ID must not be empty");
//   debugPrint('✓ ID not empty check passed');

//   require(['confirmed', 'cancelled'].contains(newStatus),
//       "Invalid status value - can only confirm or cancel");
//   debugPrint('✓ Valid status transition check passed');

//   require(widget.appointment['status'] == 'pending',
//       "Can only update status from 'pending'");
//   debugPrint('✓ Current status is pending check passed');

//   require(_auth.currentUser?.uid == widget.appointment['doctorId'],
//       "Only assigned doctor can update status");
//   debugPrint('✓ Doctor authorization check passed');

//   // CLASS INVARIANTS
//   debugPrint('\n--- Checking Class Invariants ---');
//   invariant(_auth.currentUser != null, "Doctor must be authenticated");
//   debugPrint('✓ Doctor authenticated check passed');

//   invariant(!_isLoading, "Operation already in progress");
//   debugPrint('✓ No duplicate operation check passed');

//   setState(() => _isLoading = true);
//   debugPrint('\n--- Starting Status Update Process ---');

//   try {
//     // PROCESSING INVARIANTS
//     final originalStatus = widget.appointment['status'];
//     invariant(originalStatus == 'pending', "Original status must be pending");
//     debugPrint('✓ Original status verification passed');

//     // Perform the update
//     debugPrint('Updating Firestore document...');
//     await FirebaseFirestore.instance
//         .collection('appointments')
//         .doc(widget.appointment.id)
//         .update({
//       'status': newStatus,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     // POST-CONDITION CHECKS
//     debugPrint('\n--- Verifying Post-Conditions ---');
//     debugPrint('Fetching updated document...');
//     final updatedDoc = await FirebaseFirestore.instance
//         .collection('appointments')
//         .doc(widget.appointment.id)
//         .get();

//     ensure(updatedDoc.exists, "Appointment document should still exist");
//     debugPrint('✓ Document existence check passed');

//     ensure(updatedDoc['status'] == newStatus,
//         "Status should be updated to $newStatus");
//     debugPrint('✓ Status update verification passed');

//     ensure(updatedDoc['updatedAt'] != null, "updatedAt timestamp should be set");
//     debugPrint('✓ Timestamp update verification passed');

//   } catch (e) {
//     debugPrint('Error updating status: $e');
//     rethrow;
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//     invariant(!_isLoading, "Loading flag must be reset after operation");
//   }
// }

// void require(bool condition, String message) {
//   if (!condition) {
//     throw Exception("Precondition failed: $message");
//   }
// }

// void ensure(bool condition, String message) {
//   if (!condition) {
//     throw Exception("Postcondition failed: $message");
//   }
// }

// void invariant(bool condition, String message) {
//   if (!condition) {
//     throw Exception("Invariant violated: $message");
//   }
// }

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
