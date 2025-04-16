import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/appointment_history_screen.dart';
import 'package:mediconnect/features/appointment/doctor_list_screen.dart';
import 'package:mediconnect/features/appointment/patientMyAppointmentsScreen.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Gradient Background (White)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📌 Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // 🔷 Title
                  const Text(
                    "Appointments",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Manage your bookings easily",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  // 📅 Book Appointment
                  _buildOptionCard(
                    context,
                    title: "My Appointment",
                    subtitle: "Find a doctor & schedule a visit",
                    icon: Icons.calendar_today_rounded,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PatientMyAppointmentsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 📅 Book Appointment
                  _buildOptionCard(
                    context,
                    title: "Book Appointment",
                    subtitle: "Find a doctor & schedule a visit",
                    icon: Icons.calendar_today_rounded,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 📖 View Appointment History
                  _buildOptionCard(
                    context,
                    title: "View Appointment History",
                    subtitle: "Check past and upcoming visits",
                    icon: Icons.history_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AppointmentHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // 📅 Book Appointment
                  // _buildOptionCard(
                  //   context,
                  //   title: "Join Appointment",
                  //   subtitle: "Test",
                  //   icon: Icons.calendar_today_rounded,
                  //   color: Colors.blueAccent,
                  //   onTap: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (context) => const VideoCallScreen(
                  //     //       channelName:
                  //     //           "mediconnect", // 🔴 Replace with the actual channel name
                  //     //       token:
                  //     //           "007eJxTYDg3j4f1yp1NPToSseGuutN59uYvfdaYrnHr64PpLTfjo88qMCSaWKakWhgZGllYGpgkm6UkGRqkmlhYmBomJSUaJpmarq55m94QyMiw5b85EyMDBIL43Ay5qSmZyfl5eanJJQwMAIHXI9c=", // 🔴 Replace with a valid Agora token
                  //     //     ),
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Modern Floating Card with Blue Glow Effect
  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White box
          borderRadius: BorderRadius.circular(15),

          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3), // Blue glow effect
              blurRadius: 10, // Soft shadow
              spreadRadius: 2, // More shadow spread
              offset: const Offset(0, 5), // Shadow direction
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // 🔵 Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),

              // 📜 Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),

              // ➡ Arrow Icon
              const Icon(Icons.arrow_forward_ios, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}


//WITH UPCOMING APPOINTMENTS

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mediconnect/features/appointment/appointment_history_screen.dart';
// import 'package:mediconnect/features/appointment/doctor_list_screen.dart';

// class AppointmentPage extends StatefulWidget {
//   const AppointmentPage({super.key});

//   @override
//   State<AppointmentPage> createState() => _AppointmentPageState();
// }

// class _AppointmentPageState extends State<AppointmentPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> _upcomingAppointments = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUpcomingAppointments();
//   }

//   Future<void> _fetchUpcomingAppointments() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;

//       final now = DateTime.now();
//       final querySnapshot = await _firestore
//           .collection('appointments')
//           .where('patientId', isEqualTo: userId)
//           .where('status', isEqualTo: 'approved')
//           .where('dateTime', isGreaterThanOrEqualTo: now)
//           .orderBy('dateTime')
//           .limit(3) // Show only the next 3 appointments
//           .get();

//       setState(() {
//         _upcomingAppointments = querySnapshot.docs.map((doc) {
//           final data = doc.data();
//           return {
//             'id': doc.id,
//             'doctorName': data['doctorName'] ?? 'Unknown Doctor',
//             'dateTime': (data['dateTime'] as Timestamp).toDate(),
//             'method': data['method'] ?? 'appointment',
//             'price': data['price'] ?? '\$0',
//           };
//         }).toList();
//       });
//     } catch (e) {
//       print('Error fetching appointments: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.white],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Appointments",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Manage your bookings easily",
//                     style: TextStyle(fontSize: 16, color: Colors.black54),
//                   ),
//                   const SizedBox(height: 30),

//                   // Upcoming Appointments Section
//                   if (_upcomingAppointments.isNotEmpty) ...[
//                     const Text(
//                       "Upcoming Appointments",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     ..._upcomingAppointments.map((appointment) => 
//                       _buildAppointmentCard(context, appointment),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // Book Appointment Card
//                   _buildOptionCard(
//                     context,
//                     title: "Book Appointment",
//                     subtitle: "Find a doctor & schedule a visit",
//                     icon: Icons.calendar_today_rounded,
//                     color: Colors.blueAccent,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const DoctorListScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),

//                   // View History Card
//                   _buildOptionCard(
//                     context,
//                     title: "View Appointment History",
//                     subtitle: "Check past and upcoming visits",
//                     icon: Icons.history_rounded,
//                     color: Colors.green,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const AppointmentHistoryScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> appointment) {
//     final dateTime = appointment['dateTime'] as DateTime;
//     final method = appointment['method'].toString().replaceAll('_', ' ');

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   appointment['doctorName'],
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   appointment['price'],
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${DateFormat('MMM d, y').format(dateTime)} • ${DateFormat('h:mm a').format(dateTime)}',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '${method[0].toUpperCase()}${method.substring(1)} • 30 mins',
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Keep your existing _buildOptionCard method
//   Widget _buildOptionCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, size: 30, color: color),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title,
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     Text(subtitle,
//                         style: const TextStyle(
//                             fontSize: 14, color: Colors.black54)),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.arrow_forward_ios, color: Colors.black),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }