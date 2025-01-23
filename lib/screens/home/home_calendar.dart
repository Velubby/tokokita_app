import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/team_selection_service.dart';

class HomeCalendar extends StatefulWidget {
  final bool isNow;

  const HomeCalendar({super.key, required this.isNow});

  @override
  State<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends State<HomeCalendar> {
  int _totalStock = 0;
  int _stockIn = 0;
  int _stockOut = 0;
  String? _teamId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final teamDetails = await TeamSelectionService().getSelectedTeam();
      _teamId = teamDetails['teamId'];
      if (_teamId != null) {
        await _loadTotalStock(); // Load total stock saat ini
        await _loadTransactions(); // Load transaksi masuk/keluar
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  // Load total stock dari semua items
  Future<void> _loadTotalStock() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('teamId', isEqualTo: _teamId)
        .get();

    int total = 0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      total += (data['stock'] as int?) ?? 0;
    }

    if (mounted) {
      setState(() {
        _totalStock = total;
      });
    }
  }

  Future<void> _loadTransactions() async {
    // Get date range
    final now = DateTime.now();
    final targetDate =
        widget.isNow ? now : now.subtract(const Duration(days: 1));
    final startOfDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

    // Query transactions
    final querySnapshot = await FirebaseFirestore.instance
        .collection('stock_transactions')
        .where('teamId', isEqualTo: _teamId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThanOrEqualTo: endOfDay)
        .get();

    int stockIn = 0;
    int stockOut = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final quantity = data['quantity'] as int;
      if (data['type'] == 'In') {
        stockIn += quantity;
      } else {
        stockOut += quantity;
      }
    }

    if (mounted) {
      setState(() {
        _stockIn = stockIn;
        _stockOut = stockOut;
      });
    }
  }

  String _getMonthAbbreviation(int month) {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }

  Widget _renderContainer(int total, String content, bool isEnd) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$total',
                style: const TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              const SizedBox(height: 5),
              Text(
                content,
                style: const TextStyle(color: Colors.white38, fontSize: 10.0),
              ),
            ],
          ),
          const SizedBox(width: 50),
          if (isEnd) ...[
            Container(
              height: 50,
              width: 1.0,
              color: Colors.white.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate;

    if (widget.isNow) {
      formattedDate = '${now.day} ${_getMonthAbbreviation(now.month)}';
    } else {
      formattedDate = '${now.day - 1} ${_getMonthAbbreviation(now.month)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.isNow ? 'Hari Ini' : 'Kemarin',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 10),
            Text(formattedDate, style: const TextStyle(color: Colors.white38)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _renderContainer(_totalStock, 'Total Stok', true),
            _renderContainer(_stockIn, 'Stok Masuk', true),
            _renderContainer(_stockOut, 'Stok Keluar', false),
          ],
        ),
      ],
    );
  }
}
