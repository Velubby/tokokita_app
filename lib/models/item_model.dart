import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String itemId;
  final String teamId;
  final String itemName;
  final String category;
  final String brand;
  final double price;
  final double cost;
  final int? stock;
  final DateTime createdAt;

  Item({
    required this.itemId,
    required this.teamId,
    required this.itemName,
    required this.category,
    required this.brand,
    required this.price,
    required this.cost,
    this.stock,
    required this.createdAt,
  });

  factory Item.fromMap(Map<String, dynamic> data, String id) {
    return Item(
      itemId: id,
      teamId: data['teamId'],
      itemName: data['itemName'],
      category: data['category'],
      brand: data['brand'],
      price: data['price'],
      cost: data['cost'],
      stock: data['stock'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'itemName': itemName,
      'category': category,
      'brand': brand,
      'price': price,
      'cost': cost,
      'stock': stock,
      'createdAt': createdAt,
    };
  }
}
