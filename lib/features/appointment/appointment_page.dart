// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/appointment/appointment_history_screen.dart';
// import 'package:mediconnect/features/appointment/doctor_list_screen.dart';

// class AppointmentPage extends StatelessWidget {
//   const AppointmentPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Appointments")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Manage Your Appointments",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),

//             // 📌 Book Appointment Button
//             _buildOptionCard(
//               context,
//               title: "Book Appointment",
//               subtitle: "Find a doctor and schedule an appointment",
//               icon: Icons.calendar_today,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const DoctorListScreen()),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),

//             // 📌 View Appointment History Button
//             _buildOptionCard(
//               context,
//               title: "View Appointment History",
//               subtitle: "See past and upcoming appointments",
//               icon: Icons.history,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const AppointmentHistoryScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Icon(icon, size: 40, color: Colors.blue),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title,
//                         style: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     Text(subtitle,
//                         style:
//                             const TextStyle(fontSize: 14, color: Colors.grey)),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.arrow_forward_ios, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/appointment_history_screen.dart';
import 'package:mediconnect/features/appointment/doctor_list_screen.dart';

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
