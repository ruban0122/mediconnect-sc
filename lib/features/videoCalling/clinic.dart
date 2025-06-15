class Clinic {
  final String id;
  final String name;
  final String address;
  final String status;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
  });

  factory Clinic.fromMap(Map<String, dynamic> map) {
    return Clinic(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Clinic',
      address: map['address'] ?? '',
      status: map['status'] ?? 'active',
    );
  }
}