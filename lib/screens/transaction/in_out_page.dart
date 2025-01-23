import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/models/stock_transaction_model.dart';
import '/services/team_selection_service.dart';

class InOutPage extends StatefulWidget {
  const InOutPage({super.key});

  @override
  State<InOutPage> createState() => _InOutPageState();
}

class _InOutPageState extends State<InOutPage> {
  String? _teamId;

  @override
  void initState() {
    super.initState();
    _loadTeamId();
  }

  Future<void> _loadTeamId() async {
    final teamDetails = await TeamSelectionService().getSelectedTeam();
    setState(() {
      _teamId = teamDetails['teamId'];
    });
  }

  Widget _buildTransactionCard(StockTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Time and Type Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(transaction.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SvgPicture.asset(
                  transaction.type == 'In'
                      ? 'assets/icons/in.svg'
                      : 'assets/icons/out.svg',
                  height: 20,
                  width: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item Name and Quantity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${transaction.type == 'In' ? '+' : '-'}${transaction.quantity}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Supplier/Customer Info
            if (transaction.supplierName != null ||
                transaction.customerName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  transaction.type == 'In'
                      ? 'Supplier: ${transaction.supplierName}'
                      : 'Customer: ${transaction.customerName}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(String date, List<StockTransaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...transactions.map(_buildTransactionCard),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_teamId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stock_transactions')
            .where('teamId', isEqualTo: _teamId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // Group transactions by date
          final groupedTransactions = <String, List<StockTransaction>>{};
          for (var doc in snapshot.data!.docs) {
            final transaction = StockTransaction.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            final date = DateFormat('d MMMM yyyy', 'id_ID')
                .format(transaction.createdAt);
            groupedTransactions.putIfAbsent(date, () => []).add(transaction);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final date = groupedTransactions.keys.elementAt(index);
              return _buildDateGroup(date, groupedTransactions[date]!);
            },
          );
        },
      ),
    );
  }
}
