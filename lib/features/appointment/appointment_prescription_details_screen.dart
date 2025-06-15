import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediconnect/features/videoCalling/PrescriptionItem.dart';
import 'package:mediconnect/features/videoCalling/clinic.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentListPrescriptionDetailsScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentListPrescriptionDetailsScreen(
      {super.key, required this.appointmentId});

  @override
  State<AppointmentListPrescriptionDetailsScreen> createState() =>
      _AppointmentListPrescriptionDetailsScreenState();
}

class _AppointmentListPrescriptionDetailsScreenState
    extends State<AppointmentListPrescriptionDetailsScreen> {
  Clinic? _selectedClinic;
  bool _isLoading = true;
  bool _prescriptionCollected = false;
  Map<String, dynamic>? _appointmentData;
  List<PrescriptionItem> _medications = [];
  List<Clinic> _clinics = [];
  bool _showQrCode = false;

  @override
  void initState() {
    super.initState();
    _loadAppointmentData();
    _loadClinics();
  }

  Future<void> _loadAppointmentData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .get();

      if (doc.exists) {
        setState(() {
          _appointmentData = doc.data()!;
          final status = doc['prescriptionStatus'];
          final docNotes = doc['notes'];

          _prescriptionCollected = status == 'collected';
          _showQrCode = status == 'pendingCollection';

          if (doc['prescription'] != null) {
            _medications = (doc['prescription'] as List)
                .map((item) => PrescriptionItem.fromMap(item))
                .toList();
          }

          if (doc['collectionClinicId'] != null && _clinics.isNotEmpty) {
            _selectedClinic = _clinics.firstWhere(
              (clinic) => clinic.id == doc['collectionClinicId'],
              orElse: () => _clinics.first,
            );
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading appointment: $e');
    }
  }

  Future<void> _loadClinics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .where('status', isEqualTo: 'active')
          .get();

      setState(() {
        _clinics =
            snapshot.docs.map((doc) => Clinic.fromMap(doc.data())).toList();

        if (_clinics.isNotEmpty) {
          _selectedClinic = _clinics.first;
        }
      });

      // Reload appointment data to sync clinic selection
      if (_appointmentData != null) {
        await _loadAppointmentData();
      }
    } catch (e) {
      debugPrint('Error loading clinics: $e');
    }
  }

  Future<void> _confirmCollection() async {
    if (_selectedClinic == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
        'collectionClinicId': _selectedClinic!.id,
        'prescriptionStatus': 'pendingCollection',
        'collectionRequestedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _showQrCode = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B479A)),
          ),
        ),
      );
    }

    if (_appointmentData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Appointment data not found',
            style: TextStyle(
              color: Color(0xFF101623),
              fontSize: 16,
            ),
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
          'Prescription Details',
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
        actions: [
          if (_showQrCode)
            IconButton(
              icon: const Icon(Icons.medication_outlined,
                  color: Color(0xFF199A8E)),
              onPressed: () => setState(() => _showQrCode = false),
              tooltip: 'Show Prescription',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (!_showQrCode) ...[
                _buildAppointmentHeader(),
                _buildPrescriptionSection(),
                if (!_prescriptionCollected) const SizedBox(height: 24),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 40),
                _buildQrCodeSection(),
                const SizedBox(height: 24),
                _buildCollectionConfirmationBanner(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentHeader() {
    final dateTime = (_appointmentData!['dateTime'] as Timestamp).toDate();
    final status = _appointmentData!['status'];
    final method = _appointmentData!['appointmentMethod'] ?? 'appointment';
    final price = _appointmentData!['price'] ?? 'Not specified';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_appointmentData!['doctorId'])
          .get(),
      builder: (context, doctorSnapshot) {
        if (!doctorSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctorData = doctorSnapshot.data!;
        final doctorName = doctorData['fullName'] ?? 'Unknown Doctor';
        final doctorEmail = doctorData['email'] ?? 'No email';
        final doctorImage = doctorData['profileImageUrl'];

        return SingleChildScrollView(
          //padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientHeader('Dr. $doctorName', doctorEmail, doctorImage),
              const SizedBox(height: 24),
              _buildSectionTitle("Appointment Information"),
              const SizedBox(height: 20),
              _buildInfoCard([
                _buildInfoTile(Icons.calendar_today, "Date",
                    DateFormat('MMMM dd, yyyy').format(dateTime)),
                _buildInfoTile(Icons.access_time, "Time",
                    DateFormat('hh:mm a').format(dateTime)),
                _buildInfoTile(_getMethodIcon(method), "Type",
                    method.replaceAll('_', ' ').toUpperCase()),
                _buildInfoTile(Icons.attach_money, "Fee", price.toString()),
                _buildInfoTileWithWidget(
                    Icons.info, "Status", _buildStatusBadge(status)),
                _buildInfoTile(
                  Icons.attach_money,
                  "Doctor Notes", // <-- This makes it uppercase
                  (_appointmentData!['notes'] ?? 'No notes')
                      .toString()
                      .toUpperCase(), // <-- Also uppercase
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTileWithWidget(
      IconData icon, String title, Widget subtitleWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2B479A)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              subtitleWidget,
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'messaging':
        return Icons.message;
      case 'voice_call':
        return Icons.call;
      case 'video_call':
        return Icons.videocam;
      case 'in_person':
        return Icons.person;
      default:
        return Icons.calendar_today;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey));
  }

  Widget _buildPatientHeader(String name, String email, String? imageUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null ? const Icon(Icons.person, size: 36) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Important for alignment
        children: [
          Icon(icon, color: const Color(0xFF2B479A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'pending':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange;
        break;
      case 'confirmed':
        bgColor = Colors.green.shade100;
        textColor = Colors.green;
        break;
      case 'cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red;
        break;
      case 'completed':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget _buildPrescriptionSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         '  Your Prescription',
  //         style: TextStyle(
  //           color: Color(0xFF101623),
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       if (_medications.isEmpty)
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF8FAFC),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: const Center(
  //             child: Text(
  //               'No medications prescribed',
  //               style: TextStyle(
  //                 color: Color(0xFF64748B),
  //                 fontSize: 14,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ..._medications.map((med) => _buildMedicationItem(med)).toList(),
  //       if (_prescriptionCollected)
  //         Container(
  //           margin: const EdgeInsets.only(top: 16),
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFECFDF5),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             children: [
  //               const Icon(Icons.check_circle,
  //                   color: Color(0xFF10B981), size: 20),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   'Collected on ${DateFormat('MMM dd, yyyy').format((_appointmentData!['collectedAt'] as Timestamp).toDate())}',
  //                   style: const TextStyle(
  //                     color: Color(0xFF065F46),
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildPrescriptionSection() {
    if (_medications.isEmpty) {
      // Show 'No medications prescribed' message
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Prescription',
            style: TextStyle(
              color: Color(0xFF101623),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
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
        ],
      );
    } else if (_prescriptionCollected) {
      // Medications exist and prescription is collected, show details
      return Column(
        children: [
          //_buildPrescriptionSection(),
          const SizedBox(height: 16),
          _buildCollectedStatusSection()
        ],
      );
    } else {
      // Medications exist, hide details and just show collection section
      return _buildCollectionSection();
    }
  }

  Widget _buildCollectedStatusSection() {
    final collectedAt = _appointmentData?['collectedAt'] as Timestamp?;
    final collectionDate = collectedAt != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(collectedAt.toDate())
        : 'Date not available';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prescription Collected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Collected on $collectionDate',
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(PrescriptionItem med) {
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
                  med.name,
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
                  'x${med.quantity}',
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
                _buildDetailRow('Dosage', med.dosage),
                if (med.instructions.isNotEmpty)
                  _buildDetailRow('Instructions', med.instructions),
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

  Widget _buildCollectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicine Collection',
          style: TextStyle(
            color: Color(0xFF101623),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select clinic for self-collection',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<Clinic>(
            value: _selectedClinic,
            items: _clinics
                .map((clinic) => DropdownMenuItem(
                      value: clinic,
                      child: Text(
                        clinic.name,
                        style: const TextStyle(
                          color: Color(0xFF101623),
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (clinic) => setState(() => _selectedClinic = clinic),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(
              color: Color(0xFF101623),
              fontSize: 14,
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _confirmCollection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B479A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirm Collection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeSection() {
    return Column(
      children: [
        const Text(
          'Prescription QR Code',
          style: TextStyle(
            color: Color(0xFF101623),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Show this QR code at the clinic to collect your medicine',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              QrImageView(
                data: widget.appointmentId,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 24),
              if (_selectedClinic != null) ...[
                Text(
                  _selectedClinic!.name,
                  style: const TextStyle(
                    color: Color(0xFF101623),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedClinic!.address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Generated on ${DateFormat('dd MMM yyyy - hh:mm a').format(DateTime.now())}',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionConfirmationBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B479A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2B479A), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Collection Pending',
                  style: TextStyle(
                    color: Color(0xFF101623),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clinic: ${_selectedClinic?.name ?? ''}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // TextButton(
          //   onPressed: () => setState(() => _showQrCode = false),
          //   child: Text(
          //     'Change',
          //     style: TextStyle(
          //       color: Color(0xFF199A8E),
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
