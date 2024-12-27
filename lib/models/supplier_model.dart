class Supplier {
  final String supplierId;
  final String teamId;
  final String name;

  Supplier({
    required this.supplierId,
    required this.teamId,
    required this.name,
  });

  factory Supplier.fromMap(Map<String, dynamic> data, String id) {
    return Supplier(
      supplierId: id,
      teamId: data['teamId'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'name': name,
    };
  }
}
