import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'HealthFormScreen.dart';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  Map<String, dynamic>? healthData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('records')
        .doc('health')
        .get();

    if (doc.exists) {
      setState(() {
        healthData = doc.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Medical Information',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B479A)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2B479A)),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HealthFormScreen(existingData: healthData)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : healthData == null
              ? const Center(child: Text("No health record found."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to the start
                    children: [
                      // Add your text here
                      const Text(
                        'Health Record',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(
                          height: 16), // Add some spacing between text and grid

                      // Your existing GridView
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.8,
                          children: [
                            _buildInfoCard(Icons.height, "Height",
                                "${healthData?['height']} ", Colors.blue),
                            _buildInfoCard(Icons.monitor_weight, "Weight",
                                "${healthData?['weight']} ", Colors.green),
                            _buildInfoCard(Icons.bloodtype, "Blood Type",
                                healthData?['bloodType'] ?? "N/A", Colors.red),
                            _buildInfoCard(
                                Icons.warning,
                                "Chronic",
                                healthData?['chronicDiseases'] ?? "N/A",
                                Colors.orange),
                            _buildInfoCard(
                                Icons.medication,
                                "Allergies",
                                healthData?['allergies'] ?? "N/A",
                                Colors.purple),
                            _buildInfoCard(
                                Icons.medical_services,
                                "Medications",
                                healthData?['medications'] ?? "N/A",
                                Colors.teal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String title, dynamic value, Color iconColor) {
    // Convert value to display string
    String displayValue;
    if (value == null) {
      displayValue = "N/A";
    } else if (value is List) {
      displayValue = value.isEmpty ? "None" : value.join(", ");
    } else if (value is String) {
      displayValue = value.isEmpty ? "N/A" : value;
    } else {
      displayValue = value.toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 8, spreadRadius: 2)
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 25),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(displayValue,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
