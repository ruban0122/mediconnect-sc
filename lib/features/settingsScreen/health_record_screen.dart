// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HealthRecordScreen extends StatefulWidget {
//   const HealthRecordScreen({super.key});

//   @override
//   State<HealthRecordScreen> createState() => _HealthRecordScreenState();
// }

// class _HealthRecordScreenState extends State<HealthRecordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _heightController = TextEditingController();
//   final _weightController = TextEditingController();
//   final _bloodTypeController = TextEditingController();
//   final _conditionsController = TextEditingController();
//   final _allergiesController = TextEditingController();
//   final _medicationsController = TextEditingController();
//   final _surgeriesController = TextEditingController();
//   final _bpController = TextEditingController();
//   final _sugarController = TextEditingController();
//   final _pulseController = TextEditingController();
//   final _oxygenController = TextEditingController();

//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadExistingRecord();
//   }

//   Future<void> _loadExistingRecord() async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final doc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('records')
//         .doc('health')
//         .get();

//     if (doc.exists) {
//       final data = doc.data()!;
//       _heightController.text = data['height'] ?? '';
//       _weightController.text = data['weight'] ?? '';
//       _bloodTypeController.text = data['bloodType'] ?? '';
//       _conditionsController.text = data['conditions'] ?? '';
//       _allergiesController.text = data['allergies'] ?? '';
//       _medicationsController.text = data['medications'] ?? '';
//       _surgeriesController.text = data['surgeries'] ?? '';
//       _bpController.text = data['bloodPressure'] ?? '';
//       _sugarController.text = data['bloodSugar'] ?? '';
//       _pulseController.text = data['heartRate'] ?? '';
//       _oxygenController.text = data['oxygen'] ?? '';
//     }
//   }

//   Future<void> _saveRecord() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('records')
//         .doc('health')
//         .set({
//       'height': _heightController.text,
//       'weight': _weightController.text,
//       'bloodType': _bloodTypeController.text,
//       'conditions': _conditionsController.text,
//       'allergies': _allergiesController.text,
//       'medications': _medicationsController.text,
//       'surgeries': _surgeriesController.text,
//       'bloodPressure': _bpController.text,
//       'bloodSugar': _sugarController.text,
//       'heartRate': _pulseController.text,
//       'oxygen': _oxygenController.text,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     setState(() => isLoading = false);
//     Navigator.pop(context);
//   }

//   Widget _buildField(String label, TextEditingController controller,
//       {int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//             labelText: label, border: const OutlineInputBorder()),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Health Record")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: ListView(
//                   children: [
//                     _buildField("Height (cm)", _heightController),
//                     _buildField("Weight (kg)", _weightController),
//                     _buildField("Blood Type", _bloodTypeController),
//                     _buildField("Medical Conditions", _conditionsController,
//                         maxLines: 2),
//                     _buildField("Allergies", _allergiesController),
//                     _buildField("Current Medications", _medicationsController),
//                     _buildField("Past Surgeries", _surgeriesController),
//                     _buildField("Blood Pressure", _bpController),
//                     _buildField("Blood Sugar", _sugarController),
//                     _buildField("Heart Rate", _pulseController),
//                     _buildField("Oxygen Saturation", _oxygenController),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _saveRecord,
//                       child: const Text("Save Record"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }




// //NEWWWWWWWWWWW

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// // class HealthRecordScreen extends StatefulWidget {
// //   const HealthRecordScreen({super.key});

// //   @override
// //   State<HealthRecordScreen> createState() => _HealthRecordScreenState();
// // }

// // class _HealthRecordScreenState extends State<HealthRecordScreen> {
// //   String gender = "Male";
// //   String bloodGroup = "B+";
// //   String heartRate = "60-118 bp";
// //   String weight = "68.2 kg";
// //   String chronic = "Diabetes";
// //   String lipids = "48 g";

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         elevation: 0,
// //         backgroundColor: Colors.grey[100],
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text(
// //           "Medical Information",
// //           style: TextStyle(
// //               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
// //         ),
// //         centerTitle: true,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.edit, color: Colors.black),
// //             onPressed: () {
// //               // Edit action
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: GridView.count(
// //           crossAxisCount: 2,
// //           crossAxisSpacing: 12,
// //           mainAxisSpacing: 12,
// //           childAspectRatio: 3 / 2,
// //           children: [
// //             _buildInfoCard(
// //                 "Gender", gender, FontAwesomeIcons.venusMars, Colors.blue),
// //             _buildInfoCard(
// //                 "BG", bloodGroup, FontAwesomeIcons.tint, Colors.orange),
// //             _buildInfoCard("HR", heartRate, FontAwesomeIcons.heart, Colors.red),
// //             _buildInfoCard(
// //                 "Weight", weight, FontAwesomeIcons.weight, Colors.blueGrey),
// //             _buildInfoCard("Chronic", chronic, FontAwesomeIcons.stethoscope,
// //                 Colors.redAccent),
// //             _buildInfoCard("Lipids", lipids,
// //                 FontAwesomeIcons.prescriptionBottleAlt, Colors.orangeAccent),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildInfoCard(
// //       String title, String value, IconData icon, Color color) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, size: 18, color: color),
// //               const SizedBox(width: 6),
// //               Text(
// //                 title,
// //                 style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black54),
// //               ),
// //             ],
// //           ),
// //           Text(
// //             value,
// //             style: const TextStyle(
// //                 fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
