class Category {
  final String categoryId;
  final String teamId;
  final String name;

  Category({
    required this.categoryId,
    required this.teamId,
    required this.name,
  });

  factory Category.fromMap(Map<String, dynamic> data, String id) {
    return Category(
      categoryId: id,
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
