import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediconnect/features/videoCalling/PrescriptionItem.dart';
import 'package:mediconnect/features/videoCalling/clinic.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientPrescriptionScreen extends StatefulWidget {
  final String appointmentId;

  const PatientPrescriptionScreen({super.key, required this.appointmentId});

  @override
  State<PatientPrescriptionScreen> createState() =>
      _PatientPrescriptionScreenState();
}

class _PatientPrescriptionScreenState extends State<PatientPrescriptionScreen> {
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_appointmentData == null) {
      return const Scaffold(
        body: Center(child: Text('Appointment data not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          if (_showQrCode)
            IconButton(
              icon: const Icon(Icons.medical_information),
              onPressed: () => setState(() => _showQrCode = false),
              tooltip: 'Show Prescription',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!_showQrCode) ...[
              _buildAppointmentHeader(),
              _buildPrescriptionSection(),
              if (!_prescriptionCollected) _buildCollectionSection(),
            ] else ...[
              _buildQrCodeSection(),
              _buildCollectionConfirmationBanner(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentHeader() {
    final date = (_appointmentData!['dateTime'] as Timestamp).toDate();
    final doctorName = _appointmentData!['doctorName'] ?? 'Unknown Doctor';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment with Dr. $doctorName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(date)}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (_appointmentData!['notes'] != null &&
                (_appointmentData!['notes'] as String).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Doctor\'s Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_appointmentData!['notes']),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Prescription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_medications.isEmpty)
              const Text('No medications prescribed',
                  style: TextStyle(color: Colors.grey)),
            ..._medications.map((med) => _buildMedicationItem(med)).toList(),
            if (_prescriptionCollected)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Collected on ${DateFormat('MMM dd, yyyy').format((_appointmentData!['collectedAt'] as Timestamp).toDate())}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(PrescriptionItem med) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, size: 24, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'x${med.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dosage: ${med.dosage}'),
                if (med.instructions.isNotEmpty)
                  Text('Instructions: ${med.instructions}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicine Collection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Select clinic for self-collection:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<Clinic>(
              value: _selectedClinic,
              items: _clinics
                  .map((clinic) => DropdownMenuItem(
                        value: clinic,
                        child: Text(clinic.name),
                      ))
                  .toList(),
              onChanged: (clinic) => setState(() => _selectedClinic = clinic),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmCollection,
                child: const Text('Confirm Collection'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Prescription QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Show this QR code at the clinic to collect your medicine',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: widget.appointmentId,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            if (_selectedClinic != null) ...[
              Text(
                'Clinic: ${_selectedClinic!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_selectedClinic!.address),
            ],
            const SizedBox(height: 16),
            Text(
              'Generated on ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionConfirmationBanner() {
    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Collection Pending',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Clinic: ${_selectedClinic?.name ?? ''}'),
                ],
              ),
            ),
            TextButton(
              child: const Text('Change'),
              onPressed: () => setState(() => _showQrCode = false),
            ),
          ],
        ),
      ),
    );
  }
}
