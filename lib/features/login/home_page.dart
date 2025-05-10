//import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   final String fullName;
//   const HomePage({super.key, required this.fullName});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Welcome, $fullName!',
//         style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediconnect/features/aiHealthChatBotScreen.dart';
import 'package:mediconnect/features/appointment/appointment_history_screen.dart';
import 'package:mediconnect/features/appointment/doctor_list_screen.dart';
import 'package:mediconnect/features/appointment/patientMyAppointmentsScreen.dart';
import 'package:mediconnect/features/settingsScreen/HealthRecordScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String fullName;
  final int upcomingCount;
  const HomePage({required this.fullName, required this.upcomingCount});


  @override
  State<HomePage> createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {
  // Mock user data - replace with your actual data source
  final String userName = "Patient Dudu";
  final String userHealthStatus = "Good";
  //final int upcomingAppointments = 2;
  final int pendingPrescriptions = 1;
  final int healthAlerts = 3;
 // int upcomingCount = 0;

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user greeting
              _buildHeaderSection(),
              const SizedBox(height: 24),

              // Appointments and alerts
              _buildAppointmentsSection(),
              const SizedBox(height: 24),
              const Text(
                "Quick Access",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Primary action cards
              _buildPrimaryActionSection(),
              const SizedBox(height: 24),

              // // Quick access shortcuts
              // _buildQuickAccessSection(),
              // const SizedBox(height: 24),

              // // Health insights
              _buildHealthInsightsSection(),
              const SizedBox(height: 24),

              // Emergency section
              _buildEmergencySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi, ${widget.fullName}!",
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        //const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(userHealthStatus),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Patient",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Navigate to notifications
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryActionSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.9,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildActionCard(
          icon: Icons.search,
          color: Colors.blue[600]!,
          title: "MediBot AI",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const AiHealthBotScreen()),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.local_hospital,
          color: Colors.green[600]!,
          title: "Find Doctors",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DoctorListScreen()),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.medication,
          color: Colors.orange[600]!,
          title: "Health Records",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const HealthRecordScreen()),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.emergency,
          color: Colors.red[600]!,
          title: "Emergency SOS",
          onTap: () async {
            final Uri phoneUri = Uri(scheme: 'tel', path: '999');

            try {
              bool launched = await launchUrl(
                phoneUri,
                mode: LaunchMode
                    .externalApplication, // Force external app (dialer)
              );

              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cannot launch phone dialer")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Health Overview",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoCard(
              value: widget.upcomingCount.toString(), // Use widget.upcomingCount here
              label: "Upcoming Appointments",
              icon: Icons.calendar_today,
              color: Colors.purple[400]!,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          const PatientMyAppointmentsScreen()),
                );
              },
            ),
            const SizedBox(width: 16),
            _buildInfoCard(
              value: pendingPrescriptions.toString(),
              label: "Pending Prescriptions",
              icon: Icons.description,
              color: Colors.blue[400]!,
              onTap: () {
                // Navigate to prescriptions
              },
            ),
          ],
        ),
        //const SizedBox(height: 16),
        // if (healthAlerts > 0)
        //   Container(
        //     padding: const EdgeInsets.all(16),
        //     decoration: BoxDecoration(
        //       color: Colors.red[50],
        //       borderRadius: BorderRadius.circular(12),
        //       border: Border.all(color: Colors.red[100]!),
        //     ),
        //     child: Row(
        //       children: [
        //         const Icon(Icons.warning, color: Colors.red),
        //         const SizedBox(width: 12),
        //         Expanded(
        //           child: Text(
        //             "You have $healthAlerts health alerts",
        //             style: const TextStyle(
        //               color: Colors.red,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //         ),
        //         TextButton(
        //           onPressed: () {
        //             // Navigate to alerts
        //           },
        //           child: const Text("View"),
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Access",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickAccessButton(
              icon: Icons.description,
              label: "E-Prescriptions",
              onTap: () {
                // Navigate to prescriptions
              },
            ),
            _buildQuickAccessButton(
              icon: Icons.local_hospital,
              label: "Hospital Info",
              onTap: () {
                // Navigate to hospitals
              },
            ),
            _buildQuickAccessButton(
              icon: Icons.folder,
              label: "Health Records",
              onTap: () {
                // Navigate to records
              },
            ),
            _buildQuickAccessButton(
              icon: Icons.chat,
              label: "Chat with Doctor",
              onTap: () {
                // Navigate to chat
              },
            ),
            _buildQuickAccessButton(
              icon: Icons.family_restroom,
              label: "Family Mode",
              onTap: () {
                // Switch to family mode
              },
            ),
            _buildQuickAccessButton(
              icon: Icons.delivery_dining,
              label: "Medicine Delivery",
              onTap: () {
                // Navigate to delivery
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Health Insights",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        //const SizedBox(height: 16),
        // SizedBox(
        //   height: 180,
        //   child: ListView(
        //     scrollDirection: Axis.horizontal,
        //     children: [
        //       _buildInsightCard(
        //         title: "Heart Rate Trend",
        //         value: "72 bpm",
        //         trend: Icons.trending_up,
        //         trendColor: Colors.red,
        //         onTap: () {
        //           // View detailed heart rate
        //         },
        //       ),
        //       const SizedBox(width: 12),
        //       _buildInsightCard(
        //         title: "Sleep Quality",
        //         value: "7.2 hrs",
        //         trend: Icons.trending_down,
        //         trendColor: Colors.blue,
        //         onTap: () {
        //           // View sleep analysis
        //         },
        //       ),
        //       const SizedBox(width: 12),
        //       _buildInsightCard(
        //         title: "Activity Level",
        //         value: "8,245 steps",
        //         trend: Icons.trending_up,
        //         trendColor: Colors.green,
        //         onTap: () {
        //           // View activity details
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Health Tip",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Drinking warm water with lemon in the morning can help digestion and boost immunity.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // View more tips
                  },
                  child: const Text("More Tips"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Emergency Assistance",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildEmergencyButton(
          icon: Icons.emergency,
          label: "Call Emergency Services",
          color: Colors.red,
          onTap: () async {
            final Uri phoneUri = Uri(scheme: 'tel', path: '999');

            try {
              bool launched = await launchUrl(
                phoneUri,
                mode: LaunchMode
                    .externalApplication, // Force external app (dialer)
              );

              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cannot launch phone dialer")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        _buildEmergencyButton(
          icon: Icons.local_hospital,
          label: "Nearest Hospitals",
          color: Colors.orange,
          onTap: () async {
            final Uri mapsUri = Uri.parse(
                "https://www.google.com/maps/search/?api=1&query=hospitals+near+me");

            try {
              bool launched = await launchUrl(
                mapsUri,
                mode: LaunchMode.externalApplication,
              );

              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cannot open Google Maps")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        _buildEmergencyButton(
          icon: Icons.medical_services,
          label: "First Aid Guides",
          color: Colors.purple,
          onTap: () async {
            final Uri guideUri = Uri.parse(
                "https://www.redcross.org/take-a-class/first-aid/performing-first-aid/first-aid-steps");

            try {
              bool launched = await launchUrl(
                guideUri,
                mode: LaunchMode.externalApplication,
              );

              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cannot open guide")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
        ),
      ],
    );
  }

  // Helper widget for action cards
  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for info cards
  Widget _buildInfoCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for quick access buttons
  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  // Helper widget for insight cards
  Widget _buildInsightCard({
    required String title,
    required String value,
    required IconData trend,
    required Color trendColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(trend, color: trendColor),
                const SizedBox(width: 4),
                Text(
                  "This week",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for emergency buttons
  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

}
