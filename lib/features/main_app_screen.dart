import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/appointment_page.dart';
import 'package:mediconnect/features/login/home_page.dart';
import 'aiHealthChatBotScreen.dart';
import 'settingsScreen/settings_page.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _currentIndex = 0;
  String fullName = '';
  String email = '';
  bool isLoading = true;
  int _upcomingCount = 0;
  String profileImageUrl = '';

  // Initialize pages list in initState
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pages = [
      HomePage(
          fullName: fullName,
          upcomingCount: _upcomingCount,
          profileImageUrl: profileImageUrl),
      const AppointmentPage(),
      const AiHealthBotScreen(),
      const ProfilePage(),
    ];
    fetchUpcomingAppointments();
    _fetchUserData();
  }

  Future<void> fetchUpcomingAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    print("Fetching appointments for user: ${user.uid}");
    print("Current time: $now");

    final querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'confirmed')
        .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
        .get();

    print("Upcoming confirmed appointments: ${querySnapshot.docs.length}");

    setState(() {
      _upcomingCount = querySnapshot.docs.length;
      // Update the HomePage in the pages list with the new count
      _pages[0] = HomePage(
          fullName: fullName,
          upcomingCount: _upcomingCount,
          profileImageUrl: profileImageUrl);
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          fullName = doc['fullName'] ?? '';
          email = doc['email'] ?? '';
          profileImageUrl = doc['profileImageUrl'] ?? '';
          isLoading = false;
          // Update the HomePage with the new name and count
          _pages[0] = HomePage(
              fullName: fullName,
              upcomingCount: _upcomingCount,
              profileImageUrl: profileImageUrl);
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _navigateToBookingFlow(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: AppointmentPage(), // Your first booking screen
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Appointment'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy), label: 'AI Chatbot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
