//SOFTWARE CONSTRUCTION BEFORE REFACTORING

// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/appointment/appointment_history_screen.dart';
// import 'package:mediconnect/features/appointment/doctorAppointmentsHistoryScreen.dart';
// import 'package:mediconnect/features/appointment/doctorAppointmentsUpcomingScreen.dart';
// import 'package:mediconnect/features/appointment/doctorMyAppointmentsScreen.dart';
// import 'package:mediconnect/features/appointment/doctor_list_screen.dart';

// class DoctorAppointmentPage extends StatelessWidget {
//   const DoctorAppointmentPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 🎨 Gradient Background (White)
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.white],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),

//           // 📌 Main Content
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   // 🔷 Title
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

//                   // 📅 My Appointment
//                   _buildOptionCard(
//                     context,
//                     title: "My Appointment",
//                     subtitle: "Check scheduled appointments",
//                     icon: Icons.calendar_today,
//                     color: Colors.blueAccent,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const DoctorMyAppointmentsScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),

//                   // 📅 Book Appointment
//                   _buildOptionCard(
//                     context,
//                     title: "Pending Appointment",
//                     subtitle: "Check pending approval appointments",
//                     icon: Icons.pending_actions,
//                     color: Colors.green,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const DoctorAppointmentsUpcomingScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),

//                   // 📖 View Appointment History
//                   _buildOptionCard(
//                     context,
//                     title: "View Appointment History",
//                     subtitle: "Check past appointments",
//                     icon: Icons.history_rounded,
//                     color: Colors.orange[600]!,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const DoctorAppointmentsHistoryScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 30),

//                   // // 📅 Book Appointment
//                   // _buildOptionCard(
//                   //   context,
//                   //   title: "Join Appointment",
//                   //   subtitle: "Test",
//                   //   icon: Icons.calendar_today_rounded,
//                   //   color: Colors.blueAccent,
//                   //   onTap: () {
//                   //     // Navigator.push(
//                   //     //   context,
//                   //     //   MaterialPageRoute(
//                   //     //     builder: (context) => const VideoCallScreen(
//                   //     //       channelName:
//                   //     //           "mediconnect", // 🔴 Replace with the actual channel name
//                   //     //       token:
//                   //     //           "007eJxTYDg3j4f1yp1NPToSseGuutN59uYvfdaYrnHr64PpLTfjo88qMCSaWKakWhgZGllYGpgkm6UkGRqkmlhYmBomJSUaJpmarq55m94QyMiw5b85EyMDBIL43Ay5qSmZyfl5eanJJQwMAIHXI9c=", // 🔴 Replace with a valid Agora token
//                   //     //     ),
//                   //     //   ),
//                   //     // );
//                   //   },
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 📌 Modern Floating Card with Blue Glow Effect
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
//           color: Colors.white, // White box
//           borderRadius: BorderRadius.circular(15),

//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3), // Blue glow effect
//               blurRadius: 10, // Soft shadow
//               spreadRadius: 2, // More shadow spread
//               offset: const Offset(0, 5), // Shadow direction
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             children: [
//               // 🔵 Icon Container
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, size: 30, color: color),
//               ),
//               const SizedBox(width: 16),

//               // 📜 Text Content
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

//               // ➡ Arrow Icon
//               const Icon(Icons.arrow_forward_ios, color: Colors.black),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//SOFTWARE CONSTRUCTION AFTER REFACTORING
import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/doctorAppointmentsHistoryScreen.dart';
import 'package:mediconnect/features/appointment/doctorAppointmentsUpcomingScreen.dart';
import 'package:mediconnect/features/appointment/doctorMyAppointmentsScreen.dart';

class DoctorAppointmentPage extends StatelessWidget {
  const DoctorAppointmentPage({super.key});

  final List<_AppointmentCardData> _appointmentCards = const [
    _AppointmentCardData(
      title: "My Appointment",
      subtitle: "Check scheduled appointments",
      icon: Icons.calendar_today,
      color: Colors.blueAccent,
      screen: DoctorMyAppointmentsScreen(),
    ),
    _AppointmentCardData(
      title: "Pending Appointment",
      subtitle: "Check pending approval appointments",
      icon: Icons.pending_actions,
      color: Colors.green,
      screen: DoctorAppointmentsUpcomingScreen(),
    ),
    _AppointmentCardData(
      title: "View Appointment History",
      subtitle: "Check past appointments",
      icon: Icons.history_rounded,
      color: Colors.orange,
      screen: DoctorAppointmentsHistoryScreen(),
    ),
  ];

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

                  // 🔁 Dynamic List of Option Cards
                  ..._appointmentCards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildOptionCard(
                        context,
                        title: card.title,
                        subtitle: card.subtitle,
                        icon: card.icon,
                        color: card.color,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => card.screen),
                          );
                        },
                      ),
                    );
                  }).toList(),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
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

// ✅ Card Data Model
class _AppointmentCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _AppointmentCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}
