import 'package:cloud_firestore/cloud_firestore.dart';

class StockTransaction {
  final String transactionId;
  final String teamId;
  final String type; // "In" or "Out"
  final String itemId;
  final String itemName;
  final int quantity;
  final String? supplierName; // Optional for "In" transactions
  final String? customerName; // Optional for "Out" transactions
  final DateTime createdAt;

  StockTransaction({
    required this.transactionId,
    required this.teamId,
    required this.type,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    this.supplierName,
    this.customerName,
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
      supplierName: data['supplierName'], // Optional field
      customerName: data['customerName'], // Optional field
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
      'supplierName': supplierName,
      'customerName': customerName,
      'createdAt': createdAt,
    };
  }
}
