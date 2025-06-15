// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class PendingDoctorApprovalScreen extends StatelessWidget {
//   const PendingDoctorApprovalScreen({super.key});

//   Future<void> approveDoctor(String uid) async {
//     await FirebaseFirestore.instance.collection('users').doc(uid).update({
//       'accountType': 'doctor',
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//         title: const Text(
//           'Pending Doctor Approval',
//           style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2B479A)),
//         ),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .where('accountType', isEqualTo: 'pendingDoctor')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data?.docs ?? [];

//           if (docs.isEmpty) {
//             return const Center(child: Text("No pending doctors found."));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final doctor = docs[index];
//               return Card(
//                 elevation: 3,
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   title: Text(doctor['fullName'] ?? 'No Name'),
//                   subtitle: Text(doctor['email'] ?? 'No Email'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Approve button
//                       IconButton(
//                         icon:
//                             const Icon(Icons.check_circle, color: Colors.green),
//                         tooltip: 'Approve',
//                         onPressed: () async {
//                           final confirm = await showDialog<bool>(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text("Approve Doctor?"),
//                               content: Text(
//                                   "Are you sure you want to approve Dr. ${doctor['fullName']}?"),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () =>
//                                       Navigator.pop(context, false),
//                                   child: const Text("Cancel"),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFF1E3C8D)),
//                                   child: const Text("Approve"),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (confirm == true) {
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(doctor.id)
//                                 .update({'accountType': 'doctor'});
//                             // ScaffoldMessenger.of(context).showSnackBar(
//                             //   const SnackBar(
//                             //       content:
//                             //           Text("Doctor approved successfully")),
//                             // );
//                           }
//                         },
//                       ),

//                       // Reject button
//                       IconButton(
//                         icon: const Icon(Icons.cancel, color: Colors.red),
//                         tooltip: 'Reject',
//                         onPressed: () async {
//                           final confirm = await showDialog<bool>(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text("Reject Doctor?"),
//                               content: Text(
//                                   "Are you sure you want to reject Dr. ${doctor['fullName']}?"),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () =>
//                                       Navigator.pop(context, false),
//                                   child: const Text("Cancel"),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red),
//                                   child: const Text("Reject"),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (confirm == true) {
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(doctor.id)
//                                 .update({'accountType': 'rejected'});
//                             // ScaffoldMessenger.of(context).showSnackBar(
//                             //   const SnackBar(content: Text("Doctor rejected")),
//                             // );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class PendingDoctorApprovalScreen extends StatefulWidget {
  const PendingDoctorApprovalScreen({super.key});

  @override
  State<PendingDoctorApprovalScreen> createState() =>
      _PendingDoctorApprovalScreenState();
}

class _PendingDoctorApprovalScreenState
    extends State<PendingDoctorApprovalScreen> {
  Future<void> _updateDoctorStatus(String uid, String status) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'accountType': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Pending Doctor Approvals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B479A),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF2B479A)),
            onPressed: () => _showStatsDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatsCard(context),
            const SizedBox(height: 16),
            Expanded(
              child: _buildDoctorList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where(
          'accountType',
          whereIn: ['pendingDoctor', 'doctor', 'rejected']).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final pending = snapshot.data!.docs
            .where((doc) => doc['accountType'] == 'pendingDoctor')
            .length;
        final approved = snapshot.data!.docs
            .where((doc) => doc['accountType'] == 'doctor')
            .length;
        final rejected = snapshot.data!.docs
            .where((doc) => doc['accountType'] == 'rejected')
            .length;

        return Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    Icons.pending_actions, 'Pending', pending, Colors.orange),
                _buildStatItem(
                    Icons.verified_user, 'Approved', approved, Colors.green),
                _buildStatItem(
                    Icons.do_not_disturb, 'Rejected', rejected, Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, int count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDoctorList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'pendingDoctor')
          //  .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  "No pending approvals",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const Text(
                  "All caught up!",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final doctor = docs[index];
            return OpenContainer(
              closedColor: Colors.transparent,
              closedElevation: 0,
              openColor: Colors.white,
              middleColor: Colors.white,
              closedBuilder: (context, action) =>
                  _buildDoctorCard(doctor, action),
              openBuilder: (context, action) => _buildDoctorDetails(doctor),
              tappable: false,
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorCard(QueryDocumentSnapshot doctor, VoidCallback action) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1E3C8D).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF1E3C8D)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['fullName'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['email'] ?? 'No Email',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(doctor),
                ],
              ),
              // if (doctor['specialization'] != null) ...[
              //   const SizedBox(height: 12),
              //   Wrap(
              //     spacing: 8,
              //     children: [
              //       Chip(
              //         label: Text(doctor['specialization']),
              //         backgroundColor: const Color(0xFF1E3C8D).withOpacity(0.1),
              //         labelStyle: const TextStyle(color: Color(0xFF1E3C8D)),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(QueryDocumentSnapshot doctor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => _showConfirmationDialog(
            context,
            'Approve Doctor?',
            'Are you sure you want to approve Dr. ${doctor['fullName']}?',
            () => _updateDoctorStatus(doctor.id, 'doctor'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _showConfirmationDialog(
            context,
            'Reject Doctor?',
            'Are you sure you want to reject Dr. ${doctor['fullName']}?',
            () => _updateDoctorStatus(doctor.id, 'rejected'),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorDetails(QueryDocumentSnapshot doctor) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor['fullName'] ?? 'Doctor Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _showConfirmationDialog(
              context,
              'Approve Doctor?',
              'Are you sure you want to approve Dr. ${doctor['fullName']}?',
              () => _updateDoctorStatus(doctor.id, 'doctor'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _showConfirmationDialog(
              context,
              'Reject Doctor?',
              'Are you sure you want to reject Dr. ${doctor['fullName']}?',
              () => _updateDoctorStatus(doctor.id, 'rejected'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF1E3C8D).withOpacity(0.1),
                child: const Icon(Icons.person,
                    size: 50, color: Color(0xFF1E3C8D)),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailItem('Full Name', doctor['fullName'] ?? 'Not provided'),
            _buildDetailItem('Email', doctor['email'] ?? 'Not provided'),
            // if (doctor['phone'] != null)
            //   _buildDetailItem('Phone', doctor['phone']),
            // if (doctor['specialization'] != null)
            //   _buildDetailItem('Specialization', doctor['specialization']),
            // if (doctor['licenseNumber'] != null)
            //   _buildDetailItem('License Number', doctor['licenseNumber']),
            // if (doctor['hospital'] != null)
            //   _buildDetailItem('Hospital', doctor['hospital']),
            const SizedBox(height: 24),
            const Text(
              'Registration Date',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            // Text(
            //   doctor['createdAt']?.toDate().toString() ?? 'Unknown',
            //   style: const TextStyle(fontSize: 16),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String title,
      String content, VoidCallback onConfirm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: title.contains('Approve')
                  ? const Color(0xFF2B479A)
                  : Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirm();
      if (!mounted)
        return; // ✅ FIXED: Prevent calling context if widget was disposed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(title.contains('Approve')
              ? 'Doctor approved successfully'
              : 'Doctor rejected'),
          backgroundColor:
              title.contains('Approve') ? const Color(0xFF2B479A) : Colors.red,
        ),
      );
    }
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approval Statistics'),
        content: const Text(
          'This screen shows doctors waiting for approval.\n\n'
          '• Green checkmark approves the doctor\n'
          '• Red X rejects the application\n\n'
          'Approved doctors gain full access to the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
