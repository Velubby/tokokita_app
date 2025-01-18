class Supplier {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String teamId;

  Supplier({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    required this.teamId,
  });

  factory Supplier.fromMap(Map<String, dynamic> data, String id) {
    return Supplier(
      id: id,
      name: data['name'],
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      teamId: data['teamId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'teamId': teamId,
    };
  }
}
