import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/doctorAppointmentsHistoryScreen.dart';
import 'package:mediconnect/features/appointment/doctor_availability_screen.dart';
import 'package:mediconnect/features/registration/auth_service.dart';
import 'package:mediconnect/features/settingsScreen/account_settings_page.dart';
import 'package:mediconnect/features/settingsScreen/doctorEditProfileScreen.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  String fullName = '';
  String location = '';
  String email = '';
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data();

      if (data != null) {
        setState(() {
          fullName = data['fullName'] ?? '';
          email = data['email'] ?? '';
          location = data['location'] ?? '';
          profileImageUrl = data.containsKey('profileImageUrl')
              ? data['profileImageUrl']
              : null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      //backgroundColor: const Color(0xFFF5F7FA),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        // backgroundColor: const Color(0xFFF5F7FA),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Profile Picture & Info
            Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                    GestureDetector(
                      onTap: _navigateToEditProfile,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Dr. $fullName',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Information Section
            _sectionTitle("User Information"),
            const SizedBox(height: 10),
            _profileOption(
              title: "My Profile",
              icon: Icons.person_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DoctorEditProfileScreen()),
                );
              },
            ),
            _profileOption(
              title: "My Schedule",
              icon: Icons.calendar_month,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DoctorAvailabilityScreen(
                            doctorId: FirebaseAuth.instance.currentUser!.uid,
                          )),
                );
              },
            ),
            _profileOption(
              title: "Appointment History",
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DoctorAppointmentsHistoryScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            // Settings Section
            _sectionTitle("Settings"),
            const SizedBox(height: 10),
            // _profileOption(
            //   title: "Manage Notification",
            //   icon: Icons.notifications_outlined,
            //   onTap: () {},
            // ),
            _profileOption(
              title: "Account Setting",
              icon: Icons.settings_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AccountSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _profileOption({
  //   required String title,
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: ListTile(
  //       onTap: onTap,
  //       leading: Icon(icon, color: const Color(0xFF2B479A), size: 28),
  //       title: Text(
  //         title,
  //         style: const TextStyle(fontWeight: FontWeight.w600),
  //       ),
  //       trailing:
  //           const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
  //     ),
  //   );
  // }
  Widget _profileOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.2), // Blue glow
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2B479A), size: 28),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }
}
