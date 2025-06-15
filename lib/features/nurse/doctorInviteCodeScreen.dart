import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DoctorInviteCodeScreen extends StatefulWidget {
  const DoctorInviteCodeScreen({super.key});

  @override
  State<DoctorInviteCodeScreen> createState() => _DoctorInviteCodeScreenState();
}

class _DoctorInviteCodeScreenState extends State<DoctorInviteCodeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> _generateInviteCode() async {
    final String newCode = "DOC-${_uuid.v4().substring(0, 6).toUpperCase()}";

    await _firestore.collection('doctor_invite_codes').doc(newCode).set({
      'code': newCode,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'clinicAssistantUID', // replace with actual UID
      'isReusable': true,
      'usedCount': 0,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite code generated: $newCode')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'Doctor Registration Code',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B479A)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _generateInviteCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C8D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Generate New Code",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Generated Codes",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('doctor_invite_codes')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading codes"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final code = docs[index]['code'];
                      return ListTile(
                        leading: const Icon(Icons.vpn_key),
                        title: Text(code),
                        subtitle: Text("Reusable code for doctor registration"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
