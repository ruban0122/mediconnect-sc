import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediconnect/features/nurse/prescription_confirmation_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isLoading = false;
  bool _scanCompleted = false;
  String? _lastScannedId;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(Barcode barcode) async {
    if (_scanCompleted || _isLoading) return;

    final appointmentId = barcode.rawValue;
    if (appointmentId == null || appointmentId == _lastScannedId) return;

    setState(() {
      _lastScannedId = appointmentId;
      _isLoading = true;
    });

    try {
      final isValid = await _validatePrescription(appointmentId);

      if (!mounted) return;

      if (isValid) {
        // Navigate to confirmation screen instead of showing dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrescriptionConfirmationScreen(
              appointmentId: appointmentId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid prescription QR code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _scanCompleted = true;
        });
      }
    }
  }

  Future<bool> _validatePrescription(String appointmentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .get();

    return doc.exists &&
        doc['prescriptionStatus'] == 'pendingCollection' &&
        doc['prescription'] != null;
  }

  Future<void> _showConfirmationDialog(String appointmentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .get();

    final patientName = doc['patientName'] ?? 'Patient';
    final clinicId = doc['collectionClinicId'];
    final medications = (doc['prescription'] as List).length;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: $patientName'),
            Text('Medications: $medications'),
            // Can add more details here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmCollection(appointmentId);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCollection(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'prescriptionStatus': 'collected',
        'collectedAt': FieldValue.serverTimestamp(),
        'collectedBy': FirebaseAuth.instance.currentUser!.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription collected successfully')),
      );

      // Return to home after delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'Scan Prescription',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B479A)),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _handleBarcode(barcodes.first);
              }
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          const _ScannerOverlay(),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 0.7;
    final height = size.height * 0.4;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2;

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), paint);
    canvas.drawRect(Rect.fromLTWH(0, top, left, height), paint);
    canvas.drawRect(
      Rect.fromLTWH(left + width, top, size.width - left - width, height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top + height, size.width, size.height - top - height),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFF2B479A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        const Radius.circular(20),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
