import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tokokita_app/models/stock_transaction_model.dart';

class InOutPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('stock_transactions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          final transactions = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return StockTransaction.fromMap(data, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        transaction.type == 'In' ? Colors.green : Colors.red,
                    child: Icon(
                      transaction.type == 'In'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('${transaction.type} - ${transaction.itemName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${transaction.createdAt.toLocal()}'),
                      Text('Quantity: ${transaction.quantity}'),
                      if (transaction.supplierName != null)
                        Text('Supplier: ${transaction.supplierName}'),
                      if (transaction.customerName != null)
                        Text('Customer: ${transaction.customerName}'),
                    ],
                  ),
                  trailing: Text('#${transaction.transactionId}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
