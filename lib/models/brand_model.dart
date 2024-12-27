class Brand {
  final String brandId;
  final String teamId;
  final String name;

  Brand({
    required this.brandId,
    required this.teamId,
    required this.name,
  });

  factory Brand.fromMap(Map<String, dynamic> data, String id) {
    return Brand(
      brandId: id,
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
