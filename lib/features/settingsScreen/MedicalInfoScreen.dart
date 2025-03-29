import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediconnect/features/settingsScreen/HealthFormScreen.dart';
import 'package:mediconnect/features/settingsScreen/HealthRecordScreen.dart';
import 'health_record_screen.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  bool isLoading = true;
  bool hasRecord = false;

  @override
  void initState() {
    super.initState();
    _checkMedicalRecord();
  }

  Future<void> _checkMedicalRecord() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('records')
        .doc('health')
        .get();

    if (doc.exists) {
      setState(() => hasRecord = true);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : hasRecord
            ? const HealthRecordScreen()
            : const HealthFormScreen();
  }
}
