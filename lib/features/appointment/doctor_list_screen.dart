// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/appointment/select_date_time_screen.dart';

// class DoctorListScreen extends StatefulWidget {
//   const DoctorListScreen({super.key});

//   @override
//   State<DoctorListScreen> createState() => _DoctorListScreenState();
// }

// class _DoctorListScreenState extends State<DoctorListScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   TextEditingController searchController = TextEditingController();
//   String searchQuery = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Select a Doctor")),
//       body: Column(
//         children: [
//           // 🔍 Search Bar
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: "Search Doctor",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value.toLowerCase();
//                 });
//               },
//             ),
//           ),

//           // 📌 Doctor List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore.collection('users')
//                   .where('accountType', isEqualTo: 'doctor')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var doctors = snapshot.data!.docs.where((doc) {
//                   var name = doc['fullName'].toString().toLowerCase();
//                   return searchQuery.isEmpty || name.contains(searchQuery);
//                 }).toList();

//                 if (doctors.isEmpty) {
//                   return const Center(child: Text("No doctors found"));
//                 }

//                 return ListView.builder(
//                   itemCount: doctors.length,
//                   itemBuilder: (context, index) {
//                     var doctor = doctors[index];
//                     return _buildDoctorCard(context, doctor);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDoctorCard(BuildContext context, DocumentSnapshot doctor) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 30,
//           backgroundImage: NetworkImage(doctor['profileImageUrl'] ?? ''),
//           child: doctor['profileImageUrl'] == null ? const Icon(Icons.person) : null,
//         ),
//         title: Text(doctor['fullName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         subtitle: Text(doctor['specialization'] ?? 'Specialization not available'),
//         trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SelectDateTimeScreen(doctorId: doctor.id),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/select_date_time_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Doctor"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color.fromARGB(255, 255, 255, 255)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📌 Content
          Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search Doctor",
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              // 📜 Doctor List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .where('accountType', isEqualTo: 'doctor')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var doctors = snapshot.data!.docs.where((doc) {
                      var name = doc['fullName'].toString().toLowerCase();
                      return searchQuery.isEmpty || name.contains(searchQuery);
                    }).toList();

                    if (doctors.isEmpty) {
                      return const Center(
                        child: Text(
                          "No doctors found",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        var doctor = doctors[index];
                        return _buildDoctorCard(context, doctor);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎨 Doctor Card
  Widget _buildDoctorCard(BuildContext context, DocumentSnapshot doctor) {
    return GestureDetector(
      onTap: () => _navigateToBooking(context, doctor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🏥 Doctor Profile Image
            CircleAvatar(
              radius: 35,
              backgroundImage: doctor['profileImageUrl'] != null
                  ? NetworkImage(doctor['profileImageUrl'])
                  : const AssetImage('assets/doctor_placeholder.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 15),

            // 📋 Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dr ${doctor['fullName']}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${doctor['specialization'] ?? "General"}",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),

            // ➡️ Arrow Icon
            const Icon(Icons.arrow_forward_ios,
                color: Colors.blueAccent, size: 18),
          ],
        ),
      ),
    );
  }

  // 🚀 Animated Navigation
  void _navigateToBooking(BuildContext context, DocumentSnapshot doctor) {
    // 🏥 Extract doctor details safely
    String doctorName = doctor['fullName'] ?? "Unknown Doctor";
    String specialization = doctor['specialization'] ?? "General";
    String location = doctor['address'] ?? "Not specified";
    String profileImage = doctor['profileImageUrl'] ?? "";

    // 🚀 Navigate with all required arguments
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => SelectDateTimeScreen(
          doctorId: doctor.id,
          doctorName: doctorName,
          specialization: specialization,
          location: location,
          profileImage: profileImage,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
