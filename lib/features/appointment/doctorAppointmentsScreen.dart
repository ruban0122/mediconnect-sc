import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/doctorAppointmentDetailScreen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Appointments"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Past"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList(statusFilter: ['pending', 'approved']),
            _buildAppointmentList(statusFilter: ['rejected', 'completed']),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList({required List<String> statusFilter}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: _auth.currentUser!.uid)
          .where('status', whereIn: statusFilter)
          .orderBy('dateTime', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var appointments = snapshot.data!.docs;

        if (appointments.isEmpty) {
          return const Center(child: Text("No appointments found"));
        }

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var appointment = appointments[index];
            var patientId = appointment['patientId'];
            var dateTime = (appointment['dateTime'] as Timestamp).toDate();
            //var reason = appointment['reason'];
            var status = appointment['status'];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(patientId).get(),
              builder: (context, patientSnapshot) {
                if (!patientSnapshot.hasData) {
                  return const ListTile(title: Text("Loading patient..."));
                }

                var patientData = patientSnapshot.data!;
                String patientName = patientData['fullName'];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Patient: $patientName"),
                    subtitle: Text(
                      "${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}\nStatus: $status",
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorAppointmentDetailScreen(
                            appointmentId: appointment.id,
                            patientId: patientId,
                            dateTime: dateTime,
                            // reason: reason,
                            status: status,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
