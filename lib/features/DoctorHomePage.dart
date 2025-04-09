import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/appointment_page.dart';
import 'package:mediconnect/features/appointment/doctorAppointmentPage.dart';
import 'package:mediconnect/features/appointment/doctorAppointmentsUpcomingScreen.dart';
import 'package:mediconnect/features/doctor_home_page.dart';
import 'package:mediconnect/features/login/home_page.dart';
import 'package:mediconnect/features/settingsScreen/doctorSettingsPage.dart';

import 'search_page.dart';

import 'chatbot_page.dart';
import 'settingsScreen/settings_page.dart';

class DocHomePage extends StatefulWidget {
  const DocHomePage({super.key});

  @override
  State<DocHomePage> createState() => _DocHomePageState();
}

class _DocHomePageState extends State<DocHomePage> {
  int _currentIndex = 0;
  String fullName = '';
  String email = '';
  bool isLoading = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
          isLoading = false;
          _pages = [
            DoctorHomePage(fullName: fullName),
            // const SearchPage(),
            // const BookAppointmentScreen(),
            //const AppointmentListScreen(),
           // const DoctorAppointmentsScreen(),
            const DoctorAppointmentPage(),
            // const ChatBotPage(),
            const DoctorProfilePage(),
          ];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
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
          // BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Appointment'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.smart_toy_outlined), label: 'AI Chatbot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
