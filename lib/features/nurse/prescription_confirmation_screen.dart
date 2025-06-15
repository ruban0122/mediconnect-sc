// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// class PrescriptionConfirmationScreen extends StatefulWidget {
//   final String appointmentId;

//   const PrescriptionConfirmationScreen({
//     super.key,
//     required this.appointmentId,
//   });

//   @override
//   State<PrescriptionConfirmationScreen> createState() =>
//       _PrescriptionConfirmationScreenState();
// }

// class _PrescriptionConfirmationScreenState
//     extends State<PrescriptionConfirmationScreen> {
//   double _sliderValue = 0;
//   bool _isConfirming = false;
//   Map<String, dynamic>? _appointmentData;
//   List<dynamic> _prescriptions = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadAppointmentData();
//   }

//   Future<void> _loadAppointmentData() async {
//     try {
//       final appointmentDoc = await FirebaseFirestore.instance
//           .collection('appointments')
//           .doc(widget.appointmentId)
//           .get();

//       if (appointmentDoc.exists) {
//         final patientId = appointmentDoc['patientId'];

//         // Fetch patient details
//         final patientDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(patientId)
//             .get();

//         setState(() {
//           _appointmentData = appointmentDoc.data();
//           _prescriptions = appointmentDoc['prescription'] ?? [];

//           // Add patient name to appointment data
//           if (patientDoc.exists) {
//             _appointmentData?['patientName'] =
//                 patientDoc['fullName'] ?? 'Patient';
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading data: ${e.toString()}')),
//       );
//     }
//   }

//   Future<void> _confirmCollection() async {
//     if (_sliderValue < 100) return;

//     setState(() => _isConfirming = true);

//     try {
//       await FirebaseFirestore.instance
//           .collection('appointments')
//           .doc(widget.appointmentId)
//           .update({
//         'prescriptionStatus': 'collected',
//         'collectedAt': FieldValue.serverTimestamp(),
//         'collectedBy': FirebaseAuth.instance.currentUser!.uid,
//       });

//       if (!mounted) return;

//       Navigator.pop(context); // Go back to scanner
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Prescription collected successfully')),
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isConfirming = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_appointmentData == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Confirm Prescription'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildAppointmentHeader(),
//             const SizedBox(height: 24),
//             _buildPrescriptionList(),
//             const SizedBox(height: 32),
//             _buildConfirmationSlider(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAppointmentHeader() {
//     final date = (_appointmentData!['dateTime'] as Timestamp).toDate();
//     final doctorName = _appointmentData!['doctorName'] ?? 'Unknown Doctor';
//     final patientName = _appointmentData!['patientName'] ?? 'Patient';

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Appointment Details',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Patient'),
//               subtitle: Text(patientName),
//               trailing: IconButton(
//                 icon: const Icon(Icons.refresh),
//                 onPressed: _loadAppointmentData,
//                 tooltip: 'Refresh Patient Data',
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.medical_services),
//               title: const Text('Doctor'),
//               subtitle: Text(doctorName),
//             ),
//             ListTile(
//               leading: const Icon(Icons.calendar_today),
//               title: const Text('Date'),
//               subtitle: Text(DateFormat('MMM dd, yyyy').format(date)),
//             ),
//             if (_appointmentData!['notes']?.isNotEmpty ?? false)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Divider(),
//                   const Text(
//                     'Doctor\'s Notes:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(_appointmentData!['notes']),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPrescriptionList() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Prescription (${_prescriptions.length} items)',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const Divider(),
//             if (_prescriptions.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Text(
//                   'No medications prescribed',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ..._prescriptions
//                 .map((item) => _buildPrescriptionItem(item))
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPrescriptionItem(Map<String, dynamic> item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.medication, size: 24, color: Colors.blue),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   item['name'] ?? 'Unknown Medication',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Text(
//                 'x${item['quantity'] ?? 1}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 36, top: 4),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Dosage: ${item['dosage'] ?? 'Not specified'}'),
//                 if (item['instructions']?.isNotEmpty ?? false)
//                   Text('Instructions: ${item['instructions']}'),
//               ],
//             ),
//           ),
//           const Divider(),
//         ],
//       ),
//     );
//   }

//   Widget _buildConfirmationSlider() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(
//               'Slide to confirm collection',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 16),
//             Slider(
//               value: _sliderValue,
//               min: 0,
//               max: 100,
//               divisions: 100,
//               label: _sliderValue == 100 ? 'Confirm' : 'Slide to confirm',
//               onChanged: (value) => setState(() => _sliderValue = value),
//               onChangeEnd: (value) {
//                 if (value == 100) _confirmCollection();
//               },
//             ),
//             if (_isConfirming)
//               const Padding(
//                 padding: EdgeInsets.only(top: 8),
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PrescriptionConfirmationScreen extends StatefulWidget {
  final String appointmentId;

  const PrescriptionConfirmationScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<PrescriptionConfirmationScreen> createState() =>
      _PrescriptionConfirmationScreenState();
}

class _PrescriptionConfirmationScreenState
    extends State<PrescriptionConfirmationScreen> {
  double _sliderValue = 0;
  bool _isConfirming = false;
  Map<String, dynamic>? _appointmentData;
  List<dynamic> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadAppointmentData();
  }

  Future<void> _loadAppointmentData() async {
    try {
      final appointmentDoc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .get();

      if (appointmentDoc.exists) {
        final patientId = appointmentDoc['patientId'];

        // Fetch patient details
        final patientDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(patientId)
            .get();

        setState(() {
          _appointmentData = appointmentDoc.data();
          _prescriptions = appointmentDoc['prescription'] ?? [];

          // Add patient name to appointment data
          if (patientDoc.exists) {
            _appointmentData?['patientName'] =
                patientDoc['fullName'] ?? 'Patient';
            _appointmentData?['patientImage'] = patientDoc['profileImageUrl'];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${e.toString()}'),
          backgroundColor: const Color(0xFFDC3545),
        ),
      );
    }
  }

  Future<void> _confirmCollection() async {
    if (_sliderValue < 100) return;

    setState(() => _isConfirming = true);

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
        'prescriptionStatus': 'collected',
        'collectedAt': FieldValue.serverTimestamp(),
        'collectedBy': FirebaseAuth.instance.currentUser!.uid,
      });

      if (!mounted) return;

      Navigator.pop(context); // Go back to scanner
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription collected successfully'),
          backgroundColor: Color(0xFF28A745),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_appointmentData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B479A)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Confirm Prescription',
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF101623)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentHeader(),
            const SizedBox(height: 24),
            _buildPrescriptionList(),
            const SizedBox(height: 32),
            _buildConfirmationSlider(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentHeader() {
    final dateTime = (_appointmentData!['dateTime'] as Timestamp).toDate();
    final doctorName = _appointmentData!['doctorName'] ?? 'Unknown Doctor';
    final patientName = _appointmentData!['patientName'] ?? 'Patient';
    final patientImage = _appointmentData!['patientImage'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Details',
            style: TextStyle(
              color: Color(0xFF101623),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    patientImage != null ? NetworkImage(patientImage) : null,
                child:
                    patientImage == null ? const Icon(Icons.person, size: 30) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        color: Color(0xFF101623),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Patient',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   icon: Icon(Icons.refresh, color: Color(0xFF2B479A)),
              //   onPressed: _loadAppointmentData,
              //   tooltip: 'Refresh Patient Data',
              // ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          _buildInfoTile(
            Icons.medical_services_outlined,
            'Doctor',
            'Dr. $doctorName',
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            Icons.calendar_today_outlined,
            'Date',
            DateFormat('MMMM dd, yyyy').format(dateTime),
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            Icons.access_time_outlined,
            'Time',
            DateFormat('hh:mm a').format(dateTime),
          ),
          if (_appointmentData!['notes']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            const Text(
              'Doctor\'s Notes',
              style: TextStyle(
                color: Color(0xFF101623),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _appointmentData!['notes'],
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2B479A)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF101623),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrescriptionList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prescription (${_prescriptions.length} items)',
            style: const TextStyle(
              color: Color(0xFF101623),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          if (_prescriptions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: Text(
                  'No medications prescribed',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ..._prescriptions
              .map((item) => _buildPrescriptionItem(item))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  size: 20,
                  color: Color(0xFF0C4A6E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['name'] ?? 'Unknown Medication',
                  style: const TextStyle(
                    color: Color(0xFF101623),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'x${item['quantity'] ?? 1}',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Dosage', item['dosage'] ?? 'Not specified'),
                if (item['instructions']?.isNotEmpty ?? false)
                  _buildDetailRow('Instructions', item['instructions']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Slide to confirm collection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101623),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxSliderWidth = constraints.maxWidth - 56;

                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _sliderValue += details.delta.dx;
                        _sliderValue = _sliderValue.clamp(0, maxSliderWidth);
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (_sliderValue >= maxSliderWidth) {
                        _confirmCollection();
                        setState(() => _sliderValue = maxSliderWidth);
                      } else {
                        setState(() => _sliderValue = 0);
                      }
                    },
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _sliderValue + 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _sliderValue >= maxSliderWidth
                                ? const Color(0xFF28A745)
                                : const Color(0xFF2B479A),
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        Positioned(
                          left: _sliderValue,
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _sliderValue >= maxSliderWidth
                                  ? Icons.check
                                  : Icons.arrow_forward_ios,
                              color: _sliderValue >= maxSliderWidth
                                  ? const Color(0xFF28A745)
                                  : const Color(0xFF2B479A),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              _sliderValue >= maxSliderWidth ? 'Confirmed' : '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _sliderValue >= maxSliderWidth
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          if (_isConfirming)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF2B479A)),
              ),
            ),
        ],
      ),
    );
  }

  // Widget _buildConfirmationSlider() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.blue.withOpacity(0.1),
  //           blurRadius: 10,
  //           spreadRadius: 2,
  //           offset: Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           'Slide to confirm collection',
  //           style: TextStyle(
  //             color: Color(0xFF101623),
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         Slider(
  //           value: _sliderValue,
  //           min: 0,
  //           max: 100,
  //           divisions: 100,
  //           activeColor: Color(0xFF2B479A),
  //           inactiveColor: Color(0xFFE5E7EB),
  //           thumbColor:
  //               _sliderValue == 100 ? Color(0xFF28A745) : Color(0xFF2B479A),
  //           label: _sliderValue == 100 ? 'Confirmed' : 'Slide to confirm',
  //           onChanged: (value) => setState(() => _sliderValue = value),
  //           onChangeEnd: (value) {
  //             if (value == 100) _confirmCollection();
  //           },
  //         ),
  //         if (_isConfirming)
  //           Padding(
  //             padding: EdgeInsets.only(top: 8),
  //             child: CircularProgressIndicator(
  //               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B479A)),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }
}
