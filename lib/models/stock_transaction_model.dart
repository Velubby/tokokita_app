import 'package:cloud_firestore/cloud_firestore.dart';

class StockTransaction {
  final String transactionId;
  final String teamId;
  final String type;
  final String itemId;
  final String itemName;
  final int quantity;
  final String name;
  final DateTime createdAt;

  StockTransaction({
    required this.transactionId,
    required this.teamId,
    required this.type,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.name,
    required this.createdAt,
  });

  factory StockTransaction.fromMap(Map<String, dynamic> data, String id) {
    return StockTransaction(
      transactionId: id,
      teamId: data['teamId'],
      type: data['type'],
      itemId: data['itemId'],
      itemName: data['itemName'],
      quantity: data['quantity'],
      name: data['name'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'type': type,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'name': name,
      'createdAt': createdAt,
    };
  }
}
