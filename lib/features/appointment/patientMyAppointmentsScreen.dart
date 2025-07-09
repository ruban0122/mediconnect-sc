//SOFTWARE CONSTRUCTION BEFORE REFACTORING

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mediconnect/features/appointment/doctorAppointmentDetailScreen.dart';
// import 'package:mediconnect/features/appointment/patientAppointmentDetailScreen.dart';

// class PatientMyAppointmentsScreen extends StatefulWidget {
//   const PatientMyAppointmentsScreen({super.key});

//   @override
//   State<PatientMyAppointmentsScreen> createState() =>
//       _PatientMyAppointmentsScreenState();
// }

// class _PatientMyAppointmentsScreenState
//     extends State<PatientMyAppointmentsScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _searchQuery = '';
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
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
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Color(0xFF2B479A)),
//             onPressed: () => _showSearchDialog(context),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.white, Color(0xFFF0F4FF)],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           _buildAppointmentList(statusFilter: ['confirmed'], isUpcoming: true),
//         ],
//       ),
//     );
//   }

//   Future<void> _showSearchDialog(BuildContext context) async {
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Search Appointments"),
//         content: TextField(
//           onChanged: (value) => setState(() => _searchQuery = value),
//           decoration: const InputDecoration(hintText: "Doctor name..."),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppointmentList(
//       {required List<String> statusFilter, required bool isUpcoming}) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('appointments')
//           .where('patientId', isEqualTo: _auth.currentUser!.uid)
//           .where('status', whereIn: statusFilter)
//           .orderBy('dateTime', descending: !isUpcoming)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return const Center(child: CircularProgressIndicator());

//         final appointments = snapshot.data!.docs;

//         if (appointments.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.calendar_today, size: 50, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 Text(
//                   "No ${isUpcoming ? 'upcoming' : 'past'} appointments",
//                   style: const TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: appointments.length,
//           itemBuilder: (context, index) {
//             final appointment = appointments[index];
//             return FutureBuilder<DocumentSnapshot>(
//               future: _firestore
//                   .collection('users')
//                   .doc(appointment['doctorId']) // ✅ doctor instead of patient
//                   .get(),
//               builder: (context, doctorSnapshot) {
//                 if (!doctorSnapshot.hasData) return const SizedBox.shrink();

//                 final doctorData = doctorSnapshot.data!;
//                 final doctorName = doctorData['fullName'] ?? 'Unknown Doctor';
//                 final doctorImage = doctorData['profileImageUrl'] ?? "";

//                 if (_searchQuery.isNotEmpty &&
//                     !doctorName
//                         .toLowerCase()
//                         .contains(_searchQuery.toLowerCase())) {
//                   return const SizedBox.shrink();
//                 }

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.2),
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: InkWell(
//                       onTap: () => _navigateToDetail(context, appointment),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CircleAvatar(
//                                 radius: 30,
//                                 backgroundImage: doctorImage.isNotEmpty
//                                     ? NetworkImage(doctorImage)
//                                     : const AssetImage(
//                                             'assets/doctor_placeholder.png')
//                                         as ImageProvider,
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Dr. $doctorName',
//                                       style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     Text(
//                                       DateFormat('dd-MM-yyyy HH:mm').format(
//                                           (appointment['dateTime'] as Timestamp)
//                                               .toDate()),
//                                       style: const TextStyle(
//                                           fontSize: 14, color: Colors.black54),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     _buildStatusBadge(appointment['status']),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           if (appointment['status'] == 'pending') ...[
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 _actionButton(
//                                   label: "Confirm",
//                                   color: Colors.green,
//                                   onTap: () => _updateStatus(
//                                       appointment.id, 'confirmed'),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 _actionButton(
//                                   label: "Cancel",
//                                   color: Colors.red,
//                                   onTap: () => _updateStatus(
//                                       appointment.id, 'cancelled'),
//                                 ),
//                               ],
//                             ),
//                           ]
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
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
//           style: TextStyle(color: color, fontWeight: FontWeight.bold)),
//     );
//   }

//   Future<void> _updateStatus(String appointmentId, String newStatus) async {
//     setState(() => _isLoading = true);
//     try {
//       await _firestore.collection('appointments').doc(appointmentId).update({
//         'status': newStatus,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Appointment $newStatus successfully")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update: $e")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _navigateToDetail(BuildContext context, DocumentSnapshot appointment) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             PatientAppointmentDetailScreen(appointment: appointment),
//       ),
//     );
//   }
// }

//SOFTWARE CONSTRUCTION AFTER REFACTORING
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/patientAppointmentDetailScreen.dart';

/// ====================
/// 🔶 Appointment Model
/// ====================
class Appointment {
  final String id;
  final String doctorId;
  final DateTime dateTime;
  final String status;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.dateTime,
    required this.status,
  });

  factory Appointment.fromDoc(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      doctorId: data['doctorId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }
}

/// ============================
/// 🔶 Appointment Service Class
/// ============================
class AppointmentService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Appointment>> fetchAppointmentsForPatient(
      String userId, List<String> statusFilter) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: userId)
        .where('status', whereIn: statusFilter)
        .orderBy('dateTime')
        .get();

    return snapshot.docs
        .map((doc) => Appointment.fromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<Map<String, dynamic>?> fetchDoctorData(String doctorId) async {
    final doc = await _firestore.collection('users').doc(doctorId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateAppointmentStatus(String id, String newStatus) {
    return _firestore.collection('appointments').doc(id).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

/// ===================================
/// 🔶 Appointment Filtering Logic
/// ===================================
class AppointmentFilter {
  static Future<List<Map<String, dynamic>>> filterAppointmentsWithDoctorData(
    List<Appointment> appointments,
    String query,
    Future<Map<String, dynamic>?> Function(String doctorId) getDoctorData,
  ) async {
    List<Map<String, dynamic>> result = [];

    for (var appointment in appointments) {
      final doctorData = await getDoctorData(appointment.doctorId);
      if (doctorData == null) continue;

      final doctorName = doctorData['fullName'] ?? '';
      if (query.isEmpty ||
          doctorName.toLowerCase().contains(query.toLowerCase())) {
        result.add({
          'appointment': appointment,
          'doctorData': doctorData,
        });
      }
    }

    return result;
  }
}

/// =====================================
/// 🔷 Main UI: PatientMyAppointmentsScreen
/// =====================================
class PatientMyAppointmentsScreen extends StatefulWidget {
  const PatientMyAppointmentsScreen({super.key});

  @override
  State<PatientMyAppointmentsScreen> createState() =>
      _PatientMyAppointmentsScreenState();
}

class _PatientMyAppointmentsScreenState
    extends State<PatientMyAppointmentsScreen> {
  final _auth = FirebaseAuth.instance;
  final _service = AppointmentService();

  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final appointments =
        await _service.fetchAppointmentsForPatient(userId, ['confirmed']);
    final filtered = await AppointmentFilter.filterAppointmentsWithDoctorData(
        appointments, _searchQuery, _service.fetchDoctorData);
    setState(() {
      _filteredAppointments = filtered;
      _isLoading = false;
    });
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search Appointments"),
        content: TextField(
          onChanged: (value) => _searchQuery = value,
          decoration: const InputDecoration(hintText: "Doctor name..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadAppointments();
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  // void _navigateToDetail(Appointment appointment) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           PatientAppointmentDetailScreen(appointmentId: appointment.id),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("My Appointments",
            style: TextStyle(
                color: Color(0xFF2B479A),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2B479A)),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredAppointments.isEmpty
              ? const Center(child: Text("No appointments found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final item = _filteredAppointments[index];
                    final appointment = item['appointment'] as Appointment;
                    final doctor = item['doctorData'] ?? {};
                    final doctorName = doctor['fullName'] ?? 'Unknown Doctor';
                    final doctorImage = doctor['profileImageUrl'] ?? "";

                    return _buildAppointmentCard(
                        appointment, doctorName, doctorImage);
                  },
                ),
    );
  }

  Widget _buildAppointmentCard(
      Appointment appointment, String doctorName, String doctorImage) {
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
      child: InkWell(
        //onTap: () => _navigateToDetail(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: doctorImage.isNotEmpty
                    ? NetworkImage(doctorImage)
                    : const AssetImage('assets/doctor_placeholder.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. $doctorName',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat('dd-MM-yyyy HH:mm')
                          .format(appointment.dateTime),
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    _buildStatusBadge(appointment.status),
                  ],
                ),
              ),
            ],
          ),
        ),
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
}
