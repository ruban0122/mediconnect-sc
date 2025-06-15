import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediconnect/features/videoCalling/PrescriptionItem.dart';

class FirestoreService {
  Future<void> completeAppointment({
    required String appointmentId,
    required bool needsPrescription,
    List<PrescriptionItem>? medications,
    required String notes,
    required Duration duration,
  }) async {
    final appointmentRef = FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId);

    final data = {
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'duration': duration.inSeconds,
      'notes': notes,
    };

    if (needsPrescription && medications != null) {
      data['prescription'] = medications.map((m) => m.toMap()).toList();
      data['prescriptionStatus'] = 'pending';
    }

    await appointmentRef.update(data);
  }
}