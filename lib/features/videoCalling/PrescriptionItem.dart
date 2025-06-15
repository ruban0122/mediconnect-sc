class PrescriptionItem {
  final String name;
  final String dosage;
  final String instructions;
  final int quantity;

  PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.quantity,
  });

  factory PrescriptionItem.fromMap(Map<String, dynamic> map) {
    return PrescriptionItem(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      instructions: map['instructions'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'quantity': quantity,
    };
  }
}