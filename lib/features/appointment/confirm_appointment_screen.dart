// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:mediconnect/features/appointment/booking_success_screen.dart';

// // // class ConfirmAppointmentScreen extends StatefulWidget {
// // //   final String doctorId;
// // //   final String doctorName;
// // //   final String profileImageUrl;
// // //   final String location;
// // //   final DateTime selectedDate;
// // //   final TimeOfDay selectedTime;
// // //   final String appointmentMethod;
// // //   final String appointmentPrice;
// // //   final String specialization;

// // //   const ConfirmAppointmentScreen({
// // //     super.key,
// // //     required this.doctorId,
// // //     required this.doctorName,
// // //     required this.profileImageUrl,
// // //     required this.location,
// // //     required this.selectedDate,
// // //     required this.selectedTime,
// // //     required this.appointmentMethod,
// // //     required this.appointmentPrice,
// // //     required this.specialization,
// // //   });

// // //   @override
// // //   State<ConfirmAppointmentScreen> createState() =>
// // //       _ConfirmAppointmentScreenState();
// // // }

// // // class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
// // //   bool isLoading = false;

// // //   Future<void> _confirmBooking() async {
// // //     setState(() {
// // //       isLoading = true;
// // //     });

// // //     try {
// // //       FirebaseAuth auth = FirebaseAuth.instance;
// // //       String userId = auth.currentUser!.uid;
// // //       DateTime appointmentDateTime = DateTime(
// // //         widget.selectedDate.year,
// // //         widget.selectedDate.month,
// // //         widget.selectedDate.day,
// // //         widget.selectedTime.hour,
// // //         widget.selectedTime.minute,
// // //       );

// // //       String appointmentId = "$userId-${DateTime.now().millisecondsSinceEpoch}";
// // //       await FirebaseFirestore.instance
// // //           .collection('appointments')
// // //           .doc(appointmentId)
// // //           .set({
// // //         'patientId': userId,
// // //         'doctorId': widget.doctorId,
// // //         'dateTime': appointmentDateTime.toUtc(),
// // //         'status': 'pending',
// // //         'method': widget.appointmentMethod,
// // //         'price': widget.appointmentPrice,
// // //         'createdAt': FieldValue.serverTimestamp(),
// // //         'doctorName': widget.doctorName,
// // //       });

// // //       Navigator.pushReplacement(
// // //         context,
// // //         MaterialPageRoute(
// // //           builder: (context) => const BookingSuccessScreen(),
// // //         ),
// // //       );
// // //     } catch (e) {
// // //       print("Error booking appointment: $e");
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Failed to book appointment. Try again.")),
// // //       );
// // //     } finally {
// // //       setState(() {
// // //         isLoading = false;
// // //       });
// // //     }
// // //   }

// // //   String _getMethodDescription() {
// // //     switch (widget.appointmentMethod) {
// // //       case 'messaging':
// // //         return 'Messaging';
// // //       case 'voice_call':
// // //         return 'Voice Call';
// // //       case 'video_call':
// // //         return 'Video Call';
// // //       case 'in_person':
// // //         return 'In-Person Visit';
// // //       default:
// // //         return 'Appointment';
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(
// // //         elevation: 0,
// // //         centerTitle: true,
// // //         title: const Text(
// // //           'Book Appointment',
// // //           style: TextStyle(
// // //             color: Color(0xFF2B479A),
// // //             fontSize: 18,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         backgroundColor: Colors.white,
// // //         leading: IconButton(
// // //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// // //           onPressed: () => Navigator.pop(context),
// // //         ),
// // //       ),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             // Doctor Profile
// // //             Row(
// // //               children: [
// // //                 CircleAvatar(
// // //                   radius: 40,
// // //                   backgroundImage: NetworkImage(widget.profileImageUrl),
// // //                 ),
// // //                 const SizedBox(width: 15),
// // //                 Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(
// // //                       "Dr. ${widget.doctorName}",
// // //                       style: const TextStyle(
// // //                           fontSize: 18, fontWeight: FontWeight.bold),
// // //                     ),
// // //                     Text(widget.specialization,
// // //                         style: const TextStyle(color: Colors.grey)),
// // //                     Text(
// // //                       widget.location,
// // //                       style: const TextStyle(color: Colors.grey),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),

// // //             const SizedBox(height: 20),
// // //             // const SizedBox(height: 20),

// // //             // 📅 Date Selection
// // //             const Text(
// // //               "Book Appointment",
// // //               style: TextStyle(
// // //                   fontSize: 16,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color.fromARGB(255, 110, 96, 96)),
// // //             ),

// // //             const SizedBox(height: 15),

// // //             // Appointment Details Card
// // //             Card(
// // //               elevation: 0,
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 side: BorderSide(color: Colors.grey.shade200, width: 1),
// // //               ),
// // //               child: Padding(
// // //                 padding: const EdgeInsets.all(16.0),
// // //                 child: Column(
// // //                   children: [
// // //                     _buildDetailRow(
// // //                       title: "Date & Hour",
// // //                       value:
// // //                           "${DateFormat('MMMM d, y').format(widget.selectedDate)} | ${widget.selectedTime.format(context)}",
// // //                     ),
// // //                     const Divider(height: 24, thickness: 1),
// // //                     _buildDetailRow(
// // //                       title: "Package",
// // //                       value: _getMethodDescription(),
// // //                     ),
// // //                     const Divider(height: 24, thickness: 1),
// // //                     _buildDetailRow(
// // //                       title: "Duration",
// // //                       value: "30 minutes",
// // //                     ),
// // //                     // const Divider(height: 24, thickness: 1),
// // //                     // _buildDetailRow(
// // //                     //   title: "Booking for",
// // //                     //   value: "Self",
// // //                     // ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),

// // //             const SizedBox(height: 16),

// // //             // Price Breakdown
// // //             Card(
// // //               elevation: 0,
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 side: BorderSide(color: Colors.grey.shade200, width: 1),
// // //               ),
// // //               child: Padding(
// // //                 padding: const EdgeInsets.all(16.0),
// // //                 child: Column(
// // //                   children: [
// // //                     _buildDetailRow(
// // //                       title: "Amount",
// // //                       value: widget.appointmentPrice,
// // //                     ),
// // //                     const Divider(height: 24, thickness: 1),
// // //                     _buildDetailRow(
// // //                       title: "Duration (30 mins)",
// // //                       value: "1 X ${widget.appointmentPrice}",
// // //                     ),
// // //                     const Divider(height: 24, thickness: 1),
// // //                     _buildDetailRow(
// // //                       title: "Duration",
// // //                       value: "30 minutes",
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),

// // //             const Spacer(),

// // //             // Total Price
// // //             Container(
// // //               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white,
// // //                 borderRadius: BorderRadius.circular(12),
// // //               ),
// // //               child: Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   const Text(
// // //                     "Total",
// // //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //                   ),
// // //                   Text(
// // //                     widget.appointmentPrice,
// // //                     style: const TextStyle(
// // //                       fontSize: 18,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF2B479A),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),

// // //             const SizedBox(height: 16),

// // //             // Confirm Button
// // //             SizedBox(
// // //               width: double.infinity,
// // //               child: ElevatedButton(
// // //                 onPressed: isLoading ? null : _confirmBooking,
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: const Color(0xFF2B479A),
// // //                   minimumSize: const Size(double.infinity, 50),
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(12),
// // //                   ),
// // //                 ),
// // //                 child: isLoading
// // //                     ? const CircularProgressIndicator(color: Colors.white)
// // //                     : const Text(
// // //                         "Confirm Booking",
// // //                         style: TextStyle(
// // //                           fontSize: 18,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: Colors.white,
// // //                         ),
// // //                       ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildDetailRow({required String title, required String value}) {
// // //     return Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       children: [
// // //         Text(
// // //           title,
// // //           style: const TextStyle(
// // //             fontSize: 16,
// // //             color: Colors.black,
// // //           ),
// // //         ),
// // //         Text(
// // //           value,
// // //           style: const TextStyle(
// // //             fontSize: 16,
// // //             fontWeight: FontWeight.w500,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }

// // //Software Construction

// // import 'dart:convert';

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';
// // import 'package:intl/intl.dart';
// // import 'package:mediconnect/features/appointment/booking_success_screen.dart';
// // import 'package:http/http.dart' as http;

// // class ConfirmAppointmentScreen extends StatefulWidget {
// //   final String doctorId;
// //   final String doctorName;
// //   final String profileImageUrl;
// //   final String location;
// //   final DateTime selectedDate;
// //   final TimeOfDay selectedTime;
// //   final String appointmentMethod;
// //   final String appointmentPrice;
// //   final String specialization;

// //   const ConfirmAppointmentScreen({
// //     super.key,
// //     required this.doctorId,
// //     required this.doctorName,
// //     required this.profileImageUrl,
// //     required this.location,
// //     required this.selectedDate,
// //     required this.selectedTime,
// //     required this.appointmentMethod,
// //     required this.appointmentPrice,
// //     required this.specialization,
// //   });

// //   @override
// //   State<ConfirmAppointmentScreen> createState() =>
// //       _ConfirmAppointmentScreenState();
// // }

// // class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
// //   bool isLoading = false;

// //   Future<void> _confirmBooking({
// //   required String doctorId,
// //   required String doctorName,
// //   required String patientName,
// //   required String email,
// //   required DateTime selectedDateTime,
// // }) async {
// //   try {
// //     // Amount in sen (e.g., RM15.00 = 1500)
// //     final int amountInSen = 1500;

// //     // 1. Call Cloud Function to create Stripe Checkout session
// //     final url = Uri.parse(
// //         'https://asia-southeast1-YOUR_PROJECT_ID.cloudfunctions.net/createStripeCheckoutSession');

// //     final response = await http.post(
// //       url,
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({'amount': amountInSen, 'email': email}),
// //     );

// //     final body = jsonDecode(response.body);

// //     if (response.statusCode != 200 || body['id'] == null) {
// //       throw Exception('Failed to create Stripe Checkout session');
// //     }

// //     final String sessionId = body['id'];

// //     // 2. Present Stripe Checkout
// //     await Stripe.instance.initPaymentSheet(
// //       paymentSheetParameters: SetupPaymentSheetParameters(
// //         paymentIntentClientSecret: sessionId,
// //         merchantDisplayName: 'MediConnect',
// //       ),
// //     );
// //     await Stripe.instance.presentPaymentSheet();

// //     // 3. If payment successful, save appointment in Firestore
// //     await FirebaseFirestore.instance.collection('appointments').add({
// //       'doctorId': doctorId,
// //       'doctorName': doctorName,
// //       'patientName': patientName,
// //       'email': email,
// //       'dateTime': selectedDateTime.toIso8601String(),
// //       'createdAt': Timestamp.now(),
// //       'paymentStatus': 'paid',
// //     });

// //     // Show success
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Appointment booked & payment successful!')),
// //     );
// //   } catch (e) {
// //     print('❌ Error: $e');
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Booking failed. Please try again.')),
// //     );
// //   }
// // }

// //   // //Problem-Solving 3 - Q2 - Software Construction
// //   // Future<void> _confirmBooking() async {
// //   //   // Pre-condition assertions
// //   //   assert(widget.doctorId.isNotEmpty, "Doctor ID must not be empty");
// //   //   assert(widget.doctorName.isNotEmpty, "Doctor name must not be empty");
// //   //   assert(
// //   //       widget.selectedDate
// //   //           .isAfter(DateTime.now().subtract(const Duration(days: 1))),
// //   //       "Appointment date must be in the future");
// //   //   assert(widget.appointmentMethod.isNotEmpty,
// //   //       "Appointment method must be specified");
// //   //   assert(widget.appointmentPrice.isNotEmpty,
// //   //       "Appointment price must be specified");

// //   //   setState(() {
// //   //     isLoading = true;
// //   //   });

// //   //   try {
// //   //     // Class invariant: User must be authenticated
// //   //     final auth = FirebaseAuth.instance;
// //   //     assert(auth.currentUser != null,
// //   //         "User must be logged in to book appointment");
// //   //     final userId = auth.currentUser!.uid;
// //   //     assert(userId.isNotEmpty, "User ID must not be empty");

// //   //     // Create appointment datetime with invariant checks
// //   //     final appointmentDateTime = DateTime(
// //   //       widget.selectedDate.year,
// //   //       widget.selectedDate.month,
// //   //       widget.selectedDate.day,
// //   //       widget.selectedTime.hour,
// //   //       widget.selectedTime.minute,
// //   //     );
// //   //     assert(!appointmentDateTime.isBefore(DateTime.now()),
// //   //         "Appointment time must be in the future");

// //   //     // Generate appointment ID with invariant
// //   //     final appointmentId = "$userId-${DateTime.now().millisecondsSinceEpoch}";
// //   //     assert(appointmentId.isNotEmpty, "Appointment ID must not be empty");
// //   //     assert(appointmentId.contains(userId),
// //   //         "Appointment ID must contain user ID");

// //   //     // Database operation with post-condition checks
// //   //     final docRef = FirebaseFirestore.instance
// //   //         .collection('appointments')
// //   //         .doc(appointmentId);

// //   //     final appointmentData = {
// //   //       'patientId': userId,
// //   //       'doctorId': widget.doctorId,
// //   //       'dateTime': appointmentDateTime.toUtc(),
// //   //       'status': 'pending',
// //   //       'method': widget.appointmentMethod,
// //   //       'price': widget.appointmentPrice,
// //   //       'createdAt': FieldValue.serverTimestamp(),
// //   //       'doctorName': widget.doctorName,
// //   //     };

// //   //     // Pre-write invariant: Check all required fields are present
// //   //     assert(appointmentData.containsKey('patientId'), "Missing patientId");
// //   //     assert(appointmentData.containsKey('doctorId'), "Missing doctorId");
// //   //     assert(appointmentData.containsKey('dateTime'), "Missing dateTime");

// //   //     await docRef.set(appointmentData);

// //   //     // Post-condition: Verify document was created
// //   //     final docSnapshot = await docRef.get();
// //   //     assert(docSnapshot.exists, "Appointment document was not created");
// //   //     assert(docSnapshot.data()!['patientId'] == userId,
// //   //         "Created appointment has wrong patient ID");

// //   //     // Navigation post-condition
// //   //     if (!mounted) return;
// //   //     Navigator.pushReplacement(
// //   //       context,
// //   //       MaterialPageRoute(
// //   //         builder: (context) => const BookingSuccessScreen(),
// //   //       ),
// //   //     );

// //   //     // Post-condition: Verify we're no longer on the confirm screen
// //   //     assert(!mounted || ModalRoute.of(context)?.settings.name != '/confirm',
// //   //         "Navigation to success screen failed");
// //   //   } catch (e) {
// //   //     print("Error booking appointment: $e");
// //   //     if (mounted) {
// //   //       ScaffoldMessenger.of(context).showSnackBar(
// //   //         const SnackBar(
// //   //             content: Text("Failed to book appointment. Try again.")),
// //   //       );
// //   //     }
// //   //   } finally {
// //   //     // State invariant: isLoading must be false when operation completes
// //   //     if (mounted) {
// //   //       setState(() {
// //   //         isLoading = false;
// //   //       });
// //   //     }
// //   //     assert(!isLoading, "Loading state must be false after operation");
// //   //   }
// //   // }

// //   //Problem-Solving 3 - Q3 - Software Construction
// // //   Future<void> _confirmBooking() async {
// // //   _require(widget.doctorId.isNotEmpty, "Doctor ID must not be empty");
// // //   _require(widget.doctorName.isNotEmpty, "Doctor name must not be empty");
// // //   _require(
// // //     widget.selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1))),
// // //     "Appointment date must be in the future",
// // //   );
// // //   _require(widget.appointmentMethod.isNotEmpty, "Appointment method is required");
// // //   _require(widget.appointmentPrice.isNotEmpty, "Appointment price is required");

// // //   setState(() {
// // //     isLoading = true;
// // //   });

// // //   try {
// // //     // Invariant: User must be authenticated
// // //     final auth = FirebaseAuth.instance;
// // //     final user = auth.currentUser;
// // //     _invariant(user != null, "User must be logged in");
// // //     final userId = user!.uid;
// // //     _invariant(userId.isNotEmpty, "User ID must not be empty");

// // //     // Construct appointment DateTime
// // //     final appointmentDateTime = DateTime(
// // //       widget.selectedDate.year,
// // //       widget.selectedDate.month,
// // //       widget.selectedDate.day,
// // //       widget.selectedTime.hour,
// // //       widget.selectedTime.minute,
// // //     );
// // //     _invariant(!appointmentDateTime.isBefore(DateTime.now()), "Appointment time must be in the future");

// // //     final appointmentId = "$userId-${DateTime.now().millisecondsSinceEpoch}";
// // //     _invariant(appointmentId.isNotEmpty, "Appointment ID must not be empty");
// // //     _invariant(appointmentId.contains(userId), "Appointment ID must contain user ID");

// // //     final docRef = FirebaseFirestore.instance.collection('appointments').doc(appointmentId);

// // //     final appointmentData = {
// // //       'patientId': userId,
// // //       'doctorId': widget.doctorId,
// // //       'dateTime': appointmentDateTime.toUtc(),
// // //       'status': 'pending',
// // //       'method': widget.appointmentMethod,
// // //       'price': widget.appointmentPrice,
// // //       'createdAt': FieldValue.serverTimestamp(),
// // //       'doctorName': widget.doctorName,
// // //     };

// // //     // Invariant: Required data fields present
// // //     _invariant(appointmentData.containsKey('patientId'), "Missing patientId");
// // //     _invariant(appointmentData.containsKey('doctorId'), "Missing doctorId");
// // //     _invariant(appointmentData.containsKey('dateTime'), "Missing dateTime");

// // //     await docRef.set(appointmentData);

// // //     // Postcondition: Verify document was created
// // //     final docSnapshot = await docRef.get();
// // //     _ensure(docSnapshot.exists, "Appointment document was not created");
// // //     _ensure(docSnapshot.data()?['patientId'] == userId, "Incorrect patient ID in saved document");

// // //     // Navigate to success screen
// // //     if (!mounted) return;
// // //     Navigator.pushReplacement(
// // //       context,
// // //       MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
// // //     );

// // //     // Postcondition: Should not remain on confirm screen
// // //     _ensure(!mounted || ModalRoute.of(context)?.settings.name != '/confirm', "Navigation failed");
// // //   } catch (e) {
// // //     print("Error booking appointment: $e");
// // //     if (mounted) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Failed to book appointment. Try again.")),
// // //       );
// // //     }
// // //   } finally {
// // //     if (mounted) {
// // //       setState(() {
// // //         isLoading = false;
// // //       });
// // //     }
// // //     _invariant(!isLoading, "Loading state must be false after operation");
// // //   }
// // // }

// // // void _require(bool condition, String message) {
// // //   if (!condition) {
// // //     throw Exception("Precondition failed: $message");
// // //   }
// // // }

// // // void _ensure(bool condition, String message) {
// // //   if (!condition) {
// // //     throw Exception("Postcondition failed: $message");
// // //   }
// // // }

// // // void _invariant(bool condition, String message) {
// // //   if (!condition) {
// // //     throw Exception("Invariant violated: $message");
// // //   }
// // // }

// //   String _getMethodDescription() {
// //     switch (widget.appointmentMethod) {
// //       case 'messaging':
// //         return 'Messaging';
// //       case 'voice_call':
// //         return 'Voice Call';
// //       case 'video_call':
// //         return 'Video Call';
// //       case 'in_person':
// //         return 'In-Person Visit';
// //       default:
// //         return 'Appointment';
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         elevation: 0,
// //         centerTitle: true,
// //         title: const Text(
// //           'Book Appointment',
// //           style: TextStyle(
// //             color: Color(0xFF2B479A),
// //             fontSize: 18,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         backgroundColor: Colors.white,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Doctor Profile
// //             Row(
// //               children: [
// //                 CircleAvatar(
// //                   radius: 40,
// //                   backgroundImage: NetworkImage(widget.profileImageUrl),
// //                 ),
// //                 const SizedBox(width: 15),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       "Dr. ${widget.doctorName}",
// //                       style: const TextStyle(
// //                           fontSize: 18, fontWeight: FontWeight.bold),
// //                     ),
// //                     Text(widget.specialization,
// //                         style: const TextStyle(color: Colors.grey)),
// //                     Text(
// //                       widget.location,
// //                       style: const TextStyle(color: Colors.grey),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 20),
// //             // const SizedBox(height: 20),

// //             // 📅 Date Selection
// //             const Text(
// //               "Book Appointment",
// //               style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                   color: Color.fromARGB(255, 110, 96, 96)),
// //             ),

// //             const SizedBox(height: 15),

// //             // Appointment Details Card
// //             Card(
// //               elevation: 0,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //                 side: BorderSide(color: Colors.grey.shade200, width: 1),
// //               ),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(16.0),
// //                 child: Column(
// //                   children: [
// //                     _buildDetailRow(
// //                       title: "Date & Hour",
// //                       value:
// //                           "${DateFormat('MMMM d, y').format(widget.selectedDate)} | ${widget.selectedTime.format(context)}",
// //                     ),
// //                     const Divider(height: 24, thickness: 1),
// //                     _buildDetailRow(
// //                       title: "Package",
// //                       value: _getMethodDescription(),
// //                     ),
// //                     const Divider(height: 24, thickness: 1),
// //                     _buildDetailRow(
// //                       title: "Duration",
// //                       value: "30 minutes",
// //                     ),
// //                     // const Divider(height: 24, thickness: 1),
// //                     // _buildDetailRow(
// //                     //   title: "Booking for",
// //                     //   value: "Self",
// //                     // ),
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             // Price Breakdown
// //             Card(
// //               elevation: 0,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //                 side: BorderSide(color: Colors.grey.shade200, width: 1),
// //               ),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(16.0),
// //                 child: Column(
// //                   children: [
// //                     _buildDetailRow(
// //                       title: "Amount",
// //                       value: widget.appointmentPrice,
// //                     ),
// //                     const Divider(height: 24, thickness: 1),
// //                     _buildDetailRow(
// //                       title: "Duration (30 mins)",
// //                       value: "1 X ${widget.appointmentPrice}",
// //                     ),
// //                     const Divider(height: 24, thickness: 1),
// //                     _buildDetailRow(
// //                       title: "Duration",
// //                       value: "30 minutes",
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             const Spacer(),

// //             // Total Price
// //             Container(
// //               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   const Text(
// //                     "Total",
// //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                   ),
// //                   Text(
// //                     widget.appointmentPrice,
// //                     style: const TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF2B479A),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             // Confirm Button
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: isLoading ? null : _confirmBooking,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF2B479A),
// //                   minimumSize: const Size(double.infinity, 50),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //                 child: isLoading
// //                     ? const CircularProgressIndicator(color: Colors.white)
// //                     : const Text(
// //                         "Confirm Booking",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDetailRow({required String title, required String value}) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           title,
// //           style: const TextStyle(
// //             fontSize: 16,
// //             color: Colors.black,
// //           ),
// //         ),
// //         Text(
// //           value,
// //           style: const TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:intl/intl.dart';
// import 'package:mediconnect/features/appointment/booking_success_screen.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart' as material;

// class ConfirmAppointmentScreen extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String profileImageUrl;
//   final String location;
//   final DateTime selectedDate;
//   final TimeOfDay selectedTime;
//   final String appointmentMethod;
//   final String appointmentPrice;
//   final String specialization;

//   const ConfirmAppointmentScreen({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.profileImageUrl,
//     required this.location,
//     required this.selectedDate,
//     required this.selectedTime,
//     required this.appointmentMethod,
//     required this.appointmentPrice,
//     required this.specialization,
//   });

//   @override
//   State<ConfirmAppointmentScreen> createState() =>
//       _ConfirmAppointmentScreenState();
// }

// class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
//   bool isLoading = false;

//   Future<void> _confirmBooking() async {
//   setState(() {
//     isLoading = true;
//   });

//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) throw Exception('User not logged in');

//     final email = user.email ?? '';
//     final patientName = user.displayName ?? 'Anonymous';
//     final int amountInSen =
//         (double.parse(widget.appointmentPrice.replaceAll("RM", "")) * 100).toInt();

//     final selectedDateTime = DateTime(
//       widget.selectedDate.year,
//       widget.selectedDate.month,
//       widget.selectedDate.day,
//       widget.selectedTime.hour,
//       widget.selectedTime.minute,
//     );

//     final url = Uri.parse(
//         'https://us-central1-mediconnect-d8af0.cloudfunctions.net/createPaymentIntent');

//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'amount': amountInSen, 'email': email}),
//     );

//     final body = jsonDecode(response.body);

//     if (response.statusCode != 200 || body['clientSecret'] == null) {
//       throw Exception('Failed to create PaymentIntent');
//     }

//     final String clientSecret = body['clientSecret'];

//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: clientSecret,
//         merchantDisplayName: 'MediConnect',
//         style: ThemeMode.system, // Updated for v9.5.0
//         appearance: PaymentSheetAppearance(
//           colors: PaymentSheetAppearanceColors(
//             primary: const Color(0xFF2B479A),
//           ),
//         ),
//       ),
//     );

//     FocusScope.of(context).unfocus();

//     try {
//       await Stripe.instance.presentPaymentSheet().then((value) async {
//         await FirebaseFirestore.instance.collection('appointments').add({
//           'doctorId': widget.doctorId,
//           'doctorName': widget.doctorName,
//           'patientName': patientName,
//           'email': email,
//           'dateTime': selectedDateTime.toIso8601String(),
//           'createdAt': Timestamp.now(),
//           'paymentStatus': 'paid',
//           'appointmentMethod': widget.appointmentMethod,
//           'price': widget.appointmentPrice,
//         });

//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
//         );
//       });
//     } on StripeException catch (e) {
//       print('❗StripeException: ${e.error.localizedMessage}');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.error.localizedMessage ?? 'Payment cancelled.')),
//       );
//     } catch (e) {
//       print('❌ Unexpected error: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An unexpected error occurred. Please try again.')),
//       );
//     }
//   } catch (e) {
//     print('❌ Booking error: $e');
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Booking failed. Please try again.')),
//     );
//   } finally {
//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//     });
//   }
// }

//   // Future<void> _confirmBooking() async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   try {
//   //     final user = FirebaseAuth.instance.currentUser;
//   //     if (user == null) throw Exception('User not logged in');

//   //     final email = user.email ?? '';
//   //     final patientName = user.displayName ?? 'Anonymous';
//   //     final int amountInSen =
//   //         (double.parse(widget.appointmentPrice.replaceAll("RM", "")) * 100)
//   //             .toInt();

//   //     final selectedDateTime = DateTime(
//   //       widget.selectedDate.year,
//   //       widget.selectedDate.month,
//   //       widget.selectedDate.day,
//   //       widget.selectedTime.hour,
//   //       widget.selectedTime.minute,
//   //     );

//   //     // Replace with your actual Firebase Function endpoint
//   //     final url = Uri.parse(
//   //         'https://us-central1-mediconnect-d8af0.cloudfunctions.net/createPaymentIntent');
//   //     print("Calling URL: $url");

//   //     final response = await http.post(
//   //       url,
//   //       headers: {'Content-Type': 'application/json'},
//   //       body: jsonEncode({'amount': amountInSen, 'email': email}),
//   //     );

//   //     final body = jsonDecode(response.body);

//   //     if (response.statusCode != 200 || body['clientSecret'] == null) {
//   //       throw Exception('Failed to create PaymentIntent');
//   //     }

//   //     final String clientSecret = body['clientSecret'];

//   //     await Stripe.instance.initPaymentSheet(
//   //       paymentSheetParameters: SetupPaymentSheetParameters(
//   //         paymentIntentClientSecret: clientSecret,
//   //         merchantDisplayName: 'MediConnect',
//   //       ),
//   //     );
//   //     await Stripe.instance.presentPaymentSheet();

//   //     await FirebaseFirestore.instance.collection('appointments').add({
//   //       'doctorId': widget.doctorId,
//   //       'doctorName': widget.doctorName,
//   //       'patientName': patientName,
//   //       'email': email,
//   //       'dateTime': selectedDateTime.toIso8601String(),
//   //       'createdAt': Timestamp.now(),
//   //       'paymentStatus': 'paid',
//   //       'appointmentMethod': widget.appointmentMethod,
//   //       'price': widget.appointmentPrice,
//   //     });

//   //     if (!mounted) return;
//   //     Navigator.pushReplacement(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
//   //     );
//   //   } on StripeException catch (e) {
//   //     print('❌ Stripe error: ${e.error.localizedMessage}');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //           content: Text(e.error.localizedMessage ?? 'Payment cancelled.')),
//   //     );
//   //   } catch (e) {
//   //     print('❌ Booking error: $e');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Booking failed. Please try again.')),
//   //     );
//   //   } finally {
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   String _getMethodDescription() {
//     switch (widget.appointmentMethod) {
//       case 'messaging':
//         return 'Messaging';
//       case 'voice_call':
//         return 'Voice Call';
//       case 'video_call':
//         return 'Video Call';
//       case 'in_person':
//         return 'In-Person Visit';
//       default:
//         return 'Appointment';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'Book Appointment',
//           style: TextStyle(
//             color: Color(0xFF2B479A),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundImage: NetworkImage(widget.profileImageUrl),
//                   ),
//                   const SizedBox(width: 15),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Dr. ${widget.doctorName}",
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       Text(widget.specialization,
//                           style: const TextStyle(color: Colors.grey)),
//                       Text(
//                         widget.location,
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Book Appointment",
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 110, 96, 96)),
//               ),
//               const SizedBox(height: 15),
//               _buildCard([
//                 _buildDetailRow(
//                   title: "Date & Hour",
//                   value:
//                       "${DateFormat('MMMM d, y').format(widget.selectedDate)} | ${widget.selectedTime.format(context)}",
//                 ),
//                 const Divider(height: 24, thickness: 1),
//                 _buildDetailRow(
//                   title: "Package",
//                   value: _getMethodDescription(),
//                 ),
//                 const Divider(height: 24, thickness: 1),
//                 _buildDetailRow(
//                   title: "Duration",
//                   value: "30 minutes",
//                 ),
//               ]),
//               const SizedBox(height: 16),
//               _buildCard([
//                 _buildDetailRow(
//                   title: "Amount",
//                   value: widget.appointmentPrice,
//                 ),
//                 const Divider(height: 24, thickness: 1),
//                 _buildDetailRow(
//                   title: "Duration (30 mins)",
//                   value: "1 X ${widget.appointmentPrice}",
//                 ),
//                 const Divider(height: 24, thickness: 1),
//                 _buildDetailRow(
//                   title: "Duration",
//                   value: "30 minutes",
//                 ),
//               ]),
//               const SizedBox(height: 16),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Total",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       widget.appointmentPrice,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2B479A),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : _confirmBooking,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2B479A),
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           "Confirm Booking",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCard(List<Widget> children) {
//     return material.Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(children: children),
//       ),
//     );
//   }

//   Widget _buildDetailRow({required String title, required String value}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 16, color: Colors.black),
//         ),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/booking_success_screen.dart';
import 'package:http/http.dart' as http;

class ConfirmAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String profileImageUrl;
  final String location;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String appointmentMethod;
  final String appointmentPrice;
  final String specialization;

  const ConfirmAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.profileImageUrl,
    required this.location,
    required this.selectedDate,
    required this.selectedTime,
    required this.appointmentMethod,
    required this.appointmentPrice,
    required this.specialization,
  });

  @override
  State<ConfirmAppointmentScreen> createState() =>
      _ConfirmAppointmentScreenState();
}

class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
  bool isLoading = false;
  bool isPaymentSheetOpen = false;

  Future<void> _confirmBooking() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      // Ensure widget is still mounted
      if (!mounted) return;

      // Dismiss keyboard using multiple methods for reliability
      FocusManager.instance.primaryFocus?.unfocus();
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await Future.delayed(const Duration(milliseconds: 200));

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final email = user.email ?? '';
      final patientName = user.displayName ?? 'Anonymous';
      final int amountInSen =
          (double.parse(widget.appointmentPrice.replaceAll("RM", "")) * 100)
              .toInt();

      final selectedDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        widget.selectedTime.hour,
        widget.selectedTime.minute,
      );

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final url = Uri.parse(
          'https://us-central1-mediconnect-d8af0.cloudfunctions.net/createPaymentIntent');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amountInSen, 'email': email}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode != 200 || body['clientSecret'] == null) {
        throw Exception('Failed to create PaymentIntent');
      }

      final String clientSecret = body['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'MediConnect',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF2B479A),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: const Color(0xFF2B479A),
                  text: Colors.white,
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: const Color(0xFF2B479A),
                  text: Colors.white,
                ),
              ),
            ),
          ),
          allowsDelayedPaymentMethods: false,
          billingDetails: BillingDetails(
            email: email,
            name: patientName,
          ),
        ),
      );

      // Close loading overlay
      if (mounted) Navigator.of(context).pop();

      // Additional delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() => isPaymentSheetOpen = true);

      try {
        await Stripe.instance.presentPaymentSheet();

        // Payment succeeded
        await _processSuccessfulBooking(user, selectedDateTime);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        );
      } on StripeException catch (e) {
        _handleStripeError(e);
      } on PlatformException catch (e) {
        if (e.code != 'canceled') {
          _handleGenericError('Payment failed: ${e.message}');
        }
      } catch (e) {
        _handleGenericError('An unexpected error occurred');
      } finally {
        setState(() => isPaymentSheetOpen = false);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading overlay
      _handleGenericError('Booking failed. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _processSuccessfulBooking(
      User user, DateTime selectedDateTime) async {
    await FirebaseFirestore.instance.collection('appointments').add({
      'doctorId': widget.doctorId,
      'doctorName': widget.doctorName,
      'patientId': user.uid,
      'email': user.email ?? '',
      'dateTime': Timestamp.fromDate(selectedDateTime.toUtc()),
      'createdAt': Timestamp.now(),
      'status': 'pending',
      'paymentStatus': 'paid',
      'appointmentMethod': widget.appointmentMethod,
      'price': widget.appointmentPrice,
    });
  }

  void _handleStripeError(StripeException e) {
    print('Stripe Error: ${e.error.localizedMessage}');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.error.localizedMessage ?? 'Payment failed'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleGenericError(String message) {
    print('Error: $message');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _getMethodDescription() {
    switch (widget.appointmentMethod) {
      case 'messaging':
        return 'Messaging';
      case 'voice_call':
        return 'Voice Call';
      case 'video_call':
        return 'Video Call';
      case 'in_person':
        return 'In-Person Visit';
      default:
        return 'Appointment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(widget.profileImageUrl),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${widget.doctorName}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(widget.specialization,
                          style: const TextStyle(color: Colors.grey)),
                      Text(
                        widget.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Book Appointment",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 110, 96, 96)),
              ),
              const SizedBox(height: 15),
              _buildCard([
                _buildDetailRow(
                  title: "Date & Hour",
                  value:
                      "${DateFormat('MMMM d, y').format(widget.selectedDate)} | ${widget.selectedTime.format(context)}",
                ),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                  title: "Package",
                  value: _getMethodDescription(),
                ),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                  title: "Duration",
                  value: "30 minutes",
                ),
              ]),
              const SizedBox(height: 16),
              _buildCard([
                _buildDetailRow(
                  title: "Amount",
                  value: widget.appointmentPrice,
                ),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                  title: "Duration (30 mins)",
                  value: "1 X ${widget.appointmentPrice}",
                ),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                  title: "Duration",
                  value: "30 minutes",
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.appointmentPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B479A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B479A),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Confirm Booking",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return material.Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
