class Customer {
  final String customerId;
  final String teamId;
  final String name;

  Customer({
    required this.customerId,
    required this.teamId,
    required this.name,
  });

  factory Customer.fromMap(Map<String, dynamic> data, String id) {
    return Customer(
      customerId: id,
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
