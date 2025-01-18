class ItemSearchIndex {
  final String itemId; // The ID of the item
  final String itemName; // The name of the product
  final String category; // The category of the product
  final String brand; // The brand of the product
  final double price; // The price of the product
  final double cost; // The cost of the product
  final String teamId; // The team ID (useful for multi-team apps)

  // Constructor
  ItemSearchIndex({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.brand,
    required this.price,
    required this.cost,
    required this.teamId,
  });

  // Factory method to create an ItemSearchIndex instance from Firestore data
  factory ItemSearchIndex.fromMap(Map<String, dynamic> data) {
    return ItemSearchIndex(
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      cost: data['cost']?.toDouble() ?? 0.0,
      teamId: data['teamId'] ?? '',
    );
  }

  // Method to convert an ItemSearchIndex instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'category': category,
      'brand': brand,
      'price': price,
      'cost': cost,
      'teamId': teamId,
    };
  }

  bool matchesSearch(String query) {
    return itemName.toLowerCase().contains(query.toLowerCase()) ||
        category.toLowerCase().contains(query.toLowerCase()) ||
        brand.toLowerCase().contains(query.toLowerCase());
  }
}
