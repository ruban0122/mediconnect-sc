import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String fullName;
  const HomePage({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome, $fullName!',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HomePage extends StatefulWidget {
//   final String fullName;
//   const HomePage({super.key, required this.fullName});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String? nextAppointment;
//   List<Map<String, dynamic>> healthTips = [];
//   List<Map<String, dynamic>> doctorList = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUpcomingAppointment();
//     _fetchHealthTips();
//     _fetchDoctors();
//   }

//   Future<void> _fetchUpcomingAppointment() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     final snapshot = await FirebaseFirestore.instance
//         .collection('appointments')
//         .where('userId', isEqualTo: uid)
//         .orderBy('date', descending: false)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       setState(() {
//         nextAppointment = snapshot.docs.first['date'];
//       });
//     }
//   }

//   Future<void> _fetchHealthTips() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('health_tips').limit(3).get();
//     setState(() {
//       healthTips = snapshot.docs.map((doc) => doc.data()).toList();
//     });
//   }

//   Future<void> _fetchDoctors() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('doctors').limit(3).get();
//     setState(() {
//       doctorList = snapshot.docs.map((doc) => doc.data()).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 0,
//         title: Text("Welcome, ${widget.fullName} 👋",
//             style: const TextStyle(color: Colors.white, fontSize: 18)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Quick Actions
//             _quickActions(),

//             const SizedBox(height: 20),

//             // Upcoming Appointments
//             _sectionTitle("Upcoming Appointment"),
//             nextAppointment != null
//                 ? _appointmentCard(nextAppointment!)
//                 : const Text("No upcoming appointments.", style: TextStyle(color: Colors.grey)),

//             const SizedBox(height: 20),

//             // Health Tips
//             _sectionTitle("Health Tips"),
//             healthTips.isNotEmpty
//                 ? Column(children: healthTips.map((tip) => _healthTipCard(tip)).toList())
//                 : const Text("No health tips available."),

//             const SizedBox(height: 20),

//             // Recommended Doctors
//             _sectionTitle("Recommended Doctors"),
//             doctorList.isNotEmpty
//                 ? Column(children: doctorList.map((doc) => _doctorCard(doc)).toList())
//                 : const Text("No doctors available."),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _quickActions() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _actionButton(Icons.calendar_today, "Book Appointment", () {}),
//         _actionButton(Icons.chat, "Consult Doctor", () {}),
//         _actionButton(Icons.upload_file, "Upload Records", () {}),
//       ],
//     );
//   }

//   Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.blueAccent,
//             radius: 30,
//             child: Icon(icon, size: 30, color: Colors.white),
//           ),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget _appointmentCard(String date) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Icon(Icons.calendar_today, color: Colors.blueAccent, size: 30),
//           Text("Next Appointment: $date", style: const TextStyle(fontSize: 16)),
//           ElevatedButton(onPressed: () {}, child: const Text("View")),
//         ],
//       ),
//     );
//   }

//   Widget _healthTipCard(Map<String, dynamic> tip) {
//     return Card(
//       child: ListTile(
//         leading: const Icon(Icons.health_and_safety, color: Colors.green),
//         title: Text(tip['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(tip['description']),
//       ),
//     );
//   }

//   Widget _doctorCard(Map<String, dynamic> doctor) {
//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(backgroundImage: NetworkImage(doctor['profileImageUrl'] ?? '')),
//         title: Text(doctor['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(doctor['specialization']),
//         trailing: ElevatedButton(onPressed: () {}, child: const Text("Book")),
//       ),
//     );
//   }
// }
