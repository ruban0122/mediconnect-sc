// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mediconnect/features/appointment/booking_success_screen.dart';

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
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       FirebaseAuth auth = FirebaseAuth.instance;
//       String userId = auth.currentUser!.uid;
//       DateTime appointmentDateTime = DateTime(
//         widget.selectedDate.year,
//         widget.selectedDate.month,
//         widget.selectedDate.day,
//         widget.selectedTime.hour,
//         widget.selectedTime.minute,
//       );

//       String appointmentId = "$userId-${DateTime.now().millisecondsSinceEpoch}";
//       await FirebaseFirestore.instance
//           .collection('appointments')
//           .doc(appointmentId)
//           .set({
//         'patientId': userId,
//         'doctorId': widget.doctorId,
//         'dateTime': appointmentDateTime.toUtc(),
//         'status': 'pending',
//         'method': widget.appointmentMethod,
//         'price': widget.appointmentPrice,
//         'createdAt': FieldValue.serverTimestamp(),
//         'doctorName': widget.doctorName,
//       });

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const BookingSuccessScreen(),
//         ),
//       );
//     } catch (e) {
//       print("Error booking appointment: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to book appointment. Try again.")),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

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
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Doctor Profile
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundImage: NetworkImage(widget.profileImageUrl),
//                 ),
//                 const SizedBox(width: 15),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Dr. ${widget.doctorName}",
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(widget.specialization,
//                         style: const TextStyle(color: Colors.grey)),
//                     Text(
//                       widget.location,
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),
//             // const SizedBox(height: 20),

//             // 📅 Date Selection
//             const Text(
//               "Book Appointment",
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 110, 96, 96)),
//             ),

//             const SizedBox(height: 15),

//             // Appointment Details Card
//             Card(
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: BorderSide(color: Colors.grey.shade200, width: 1),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     _buildDetailRow(
//                       title: "Date & Hour",
//                       value:
//                           "${DateFormat('MMMM d, y').format(widget.selectedDate)} | ${widget.selectedTime.format(context)}",
//                     ),
//                     const Divider(height: 24, thickness: 1),
//                     _buildDetailRow(
//                       title: "Package",
//                       value: _getMethodDescription(),
//                     ),
//                     const Divider(height: 24, thickness: 1),
//                     _buildDetailRow(
//                       title: "Duration",
//                       value: "30 minutes",
//                     ),
//                     // const Divider(height: 24, thickness: 1),
//                     // _buildDetailRow(
//                     //   title: "Booking for",
//                     //   value: "Self",
//                     // ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Price Breakdown
//             Card(
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: BorderSide(color: Colors.grey.shade200, width: 1),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     _buildDetailRow(
//                       title: "Amount",
//                       value: widget.appointmentPrice,
//                     ),
//                     const Divider(height: 24, thickness: 1),
//                     _buildDetailRow(
//                       title: "Duration (30 mins)",
//                       value: "1 X ${widget.appointmentPrice}",
//                     ),
//                     const Divider(height: 24, thickness: 1),
//                     _buildDetailRow(
//                       title: "Duration",
//                       value: "30 minutes",
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const Spacer(),

//             // Total Price
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Total",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     widget.appointmentPrice,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2B479A),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Confirm Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : _confirmBooking,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2B479A),
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         "Confirm Booking",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow({required String title, required String value}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             color: Colors.black,
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

//Software Construction

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/booking_success_screen.dart';

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

 //Problem-Solving 3 - Q2 - Software Construction
  Future<void> _confirmBooking() async {
    // Pre-condition assertions
    assert(widget.doctorId.isNotEmpty, "Doctor ID must not be empty");
    assert(widget.doctorName.isNotEmpty, "Doctor name must not be empty");
    assert(widget.selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1))),
        "Appointment date must be in the future");
    assert(widget.appointmentMethod.isNotEmpty,"Appointment method must be specified");
    assert(widget.appointmentPrice.isNotEmpty,"Appointment price must be specified");

    setState(() {
      isLoading = true;
    });

    try {
      // Class invariant: User must be authenticated
      final auth = FirebaseAuth.instance;
      assert(auth.currentUser != null,
          "User must be logged in to book appointment");
      final userId = auth.currentUser!.uid;
      assert(userId.isNotEmpty, "User ID must not be empty");

      // Create appointment datetime with invariant checks
      final appointmentDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        widget.selectedTime.hour,
        widget.selectedTime.minute,
      );
      assert(!appointmentDateTime.isBefore(DateTime.now()),
          "Appointment time must be in the future");

      // Generate appointment ID with invariant
      final appointmentId = "$userId-${DateTime.now().millisecondsSinceEpoch}";
      assert(appointmentId.isNotEmpty, "Appointment ID must not be empty");
      assert(appointmentId.contains(userId),
          "Appointment ID must contain user ID");

      // Database operation with post-condition checks
      final docRef = FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId);

      final appointmentData = {
        'patientId': userId,
        'doctorId': widget.doctorId,
        'dateTime': appointmentDateTime.toUtc(),
        'status': 'pending',
        'method': widget.appointmentMethod,
        'price': widget.appointmentPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'doctorName': widget.doctorName,
      };

      // Pre-write invariant: Check all required fields are present
      assert(appointmentData.containsKey('patientId'), "Missing patientId");
      assert(appointmentData.containsKey('doctorId'), "Missing doctorId");
      assert(appointmentData.containsKey('dateTime'), "Missing dateTime");

      await docRef.set(appointmentData);

      // Post-condition: Verify document was created
      final docSnapshot = await docRef.get();
      assert(docSnapshot.exists, "Appointment document was not created");
      assert(docSnapshot.data()!['patientId'] == userId,
          "Created appointment has wrong patient ID");

      // Navigation post-condition
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BookingSuccessScreen(),
        ),
      );

      // Post-condition: Verify we're no longer on the confirm screen
      assert(!mounted || ModalRoute.of(context)?.settings.name != '/confirm',
          "Navigation to success screen failed");
    } catch (e) {
      print("Error booking appointment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to book appointment. Try again.")),
        );
      }
    } finally {
      // State invariant: isLoading must be false when operation completes
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      assert(!isLoading, "Loading state must be false after operation");
    }
  }


  //Problem-Solving 3 - Q3 - Software Construction
//   Future<void> _confirmBooking() async {
//   _require(widget.doctorId.isNotEmpty, "Doctor ID must not be empty");
//   _require(widget.doctorName.isNotEmpty, "Doctor name must not be empty");
//   _require(
//     widget.selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1))),
//     "Appointment date must be in the future",
//   );
//   _require(widget.appointmentMethod.isNotEmpty, "Appointment method is required");
//   _require(widget.appointmentPrice.isNotEmpty, "Appointment price is required");

//   setState(() {
//     isLoading = true;
//   });

//   try {
//     // Invariant: User must be authenticated
//     final auth = FirebaseAuth.instance;
//     final user = auth.currentUser;
//     _invariant(user != null, "User must be logged in");
//     final userId = user!.uid;
//     _invariant(userId.isNotEmpty, "User ID must not be empty");

//     // Construct appointment DateTime
//     final appointmentDateTime = DateTime(
//       widget.selectedDate.year,
//       widget.selectedDate.month,
//       widget.selectedDate.day,
//       widget.selectedTime.hour,
//       widget.selectedTime.minute,
//     );
//     _invariant(!appointmentDateTime.isBefore(DateTime.now()), "Appointment time must be in the future");

//     final appointmentId = "$userId-${DateTime.now().millisecondsSinceEpoch}";
//     _invariant(appointmentId.isNotEmpty, "Appointment ID must not be empty");
//     _invariant(appointmentId.contains(userId), "Appointment ID must contain user ID");

//     final docRef = FirebaseFirestore.instance.collection('appointments').doc(appointmentId);

//     final appointmentData = {
//       'patientId': userId,
//       'doctorId': widget.doctorId,
//       'dateTime': appointmentDateTime.toUtc(),
//       'status': 'pending',
//       'method': widget.appointmentMethod,
//       'price': widget.appointmentPrice,
//       'createdAt': FieldValue.serverTimestamp(),
//       'doctorName': widget.doctorName,
//     };

//     // Invariant: Required data fields present
//     _invariant(appointmentData.containsKey('patientId'), "Missing patientId");
//     _invariant(appointmentData.containsKey('doctorId'), "Missing doctorId");
//     _invariant(appointmentData.containsKey('dateTime'), "Missing dateTime");

//     await docRef.set(appointmentData);

//     // Postcondition: Verify document was created
//     final docSnapshot = await docRef.get();
//     _ensure(docSnapshot.exists, "Appointment document was not created");
//     _ensure(docSnapshot.data()?['patientId'] == userId, "Incorrect patient ID in saved document");

//     // Navigate to success screen
//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
//     );

//     // Postcondition: Should not remain on confirm screen
//     _ensure(!mounted || ModalRoute.of(context)?.settings.name != '/confirm', "Navigation failed");
//   } catch (e) {
//     print("Error booking appointment: $e");
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to book appointment. Try again.")),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//     _invariant(!isLoading, "Loading state must be false after operation");
//   }
// }

// void _require(bool condition, String message) {
//   if (!condition) {
//     throw Exception("Precondition failed: $message");
//   }
// }

// void _ensure(bool condition, String message) {
//   if (!condition) {
//     throw Exception("Postcondition failed: $message");
//   }
// }

// void _invariant(bool condition, String message) {
//   if (!condition) {
//     throw Exception("Invariant violated: $message");
//   }
// }




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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile
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
            // const SizedBox(height: 20),

            // 📅 Date Selection
            const Text(
              "Book Appointment",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 110, 96, 96)),
            ),

            const SizedBox(height: 15),

            // Appointment Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                    // const Divider(height: 24, thickness: 1),
                    // _buildDetailRow(
                    //   title: "Booking for",
                    //   value: "Self",
                    // ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Price Breakdown
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Total Price
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // Confirm Button
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
