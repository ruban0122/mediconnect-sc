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

import 'package:flutter/material.dart';

import 'package:mediconnect/features/aiHealthChatBotScreen.dart';

import 'package:mediconnect/features/appointment/doctor_list_screen.dart';
import 'package:mediconnect/features/appointment/patientMyAppointmentsScreen.dart';
import 'package:mediconnect/features/settingsScreen/HealthRecordScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String fullName;
  final int upcomingCount;
  final String profileImageUrl;
  const HomePage(
      {required this.fullName,
      required this.upcomingCount,
      required this.profileImageUrl});

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.blue.withOpacity(0.3),
        //     blurRadius: 15,
        //     //offset: const Offset(12, 40),
        //   ),
        // ],
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B479A).withOpacity(0.3), // Use theme color
            blurRadius: 15,
            //spreadRadius: 1, // Adds subtle expansion
            offset: const Offset(0, 4), // Subtle downward shadow
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side - User Info
          Expanded(
            child: Row(
              children: [
                // Profile Avatar with Status Indicator
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getStatusColor(userHealthStatus),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: widget.profileImageUrl.isNotEmpty
                            ? Image.network(
                                widget.profileImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultAvatar(),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                    // Container(
                    //   width: 14,
                    //   height: 14,
                    //   decoration: BoxDecoration(
                    //     color: _getStatusColor(userHealthStatus),
                    //     shape: BoxShape.circle,
                    //     border: Border.all(
                    //       color: Colors.white,
                    //       width: 2,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(width: 16),

                // User Greeting and Role
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B479A), // Using your theme color
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(userHealthStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _getStatusColor(userHealthStatus),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Patient",
                        style: TextStyle(
                          color: _getStatusColor(userHealthStatus),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Side - Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[700],
                  size: 28,
                ),
                onPressed: () {
                  // Navigate to notifications screen
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 32,
      ),
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
              value: widget.upcomingCount
                  .toString(), // Use widget.upcomingCount here
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
            // const SizedBox(width: 16),
            // _buildInfoCard(
            //   value: pendingPrescriptions.toString(),
            //   label: "Pending Prescriptions",
            //   icon: Icons.description,
            //   color: Colors.blue[400]!,
            //   onTap: () {
            //     // Navigate to prescriptions
            //   },
            // ),
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

  Future<String> fetchTodaysTip() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('healthTips')
        .doc('daily_tips')
        .get();

    final tips = snapshot.data() as Map<String, dynamic>;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final tipKey = 'tip${(dayOfYear % tips.length) + 1}'; // Cycles through tips

    return tips[tipKey] ?? "Stay hydrated for better health!";
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
        const SizedBox(height: 12),
        FutureBuilder<String>(
          future: fetchTodaysTip(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final todaysTip = snapshot.data ?? "Stay healthy and active!";

            return Container(
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
                  Text(
                    todaysTip,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       // Navigate to a tips screen
                  //     },
                  //     child: const Text("More Tips"),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget _buildHealthInsightsSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         "Health Insights",
  //         style: TextStyle(
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       //const SizedBox(height: 16),
  //       // SizedBox(
  //       //   height: 180,
  //       //   child: ListView(
  //       //     scrollDirection: Axis.horizontal,
  //       //     children: [
  //       //       _buildInsightCard(
  //       //         title: "Heart Rate Trend",
  //       //         value: "72 bpm",
  //       //         trend: Icons.trending_up,
  //       //         trendColor: Colors.red,
  //       //         onTap: () {
  //       //           // View detailed heart rate
  //       //         },
  //       //       ),
  //       //       const SizedBox(width: 12),
  //       //       _buildInsightCard(
  //       //         title: "Sleep Quality",
  //       //         value: "7.2 hrs",
  //       //         trend: Icons.trending_down,
  //       //         trendColor: Colors.blue,
  //       //         onTap: () {
  //       //           // View sleep analysis
  //       //         },
  //       //       ),
  //       //       const SizedBox(width: 12),
  //       //       _buildInsightCard(
  //       //         title: "Activity Level",
  //       //         value: "8,245 steps",
  //       //         trend: Icons.trending_up,
  //       //         trendColor: Colors.green,
  //       //         onTap: () {
  //       //           // View activity details
  //       //         },
  //       //       ),
  //       //     ],
  //       //   ),
  //       // ),
  //       const SizedBox(height: 12),
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.blue[50],
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               "Today's Health Tip",
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text(
  //               "Drinking warm water with lemon in the morning can help digestion and boost immunity.",
  //               style: TextStyle(fontSize: 14),
  //             ),
  //             const SizedBox(height: 8),
  //             Align(
  //               alignment: Alignment.centerRight,
  //               child: TextButton(
  //                 onPressed: () {
  //                   // View more tips
  //                 },
  //                 child: const Text("More Tips"),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
        return const Color(0xFF2B479A);

      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
