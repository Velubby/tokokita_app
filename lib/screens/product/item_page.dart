import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tokokita_app/screens/home/add_in_out/add_product_page.dart';

class ItemsPage extends StatefulWidget {
  final String teamId;

  const ItemsPage({super.key, required this.teamId});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  String _sortBy = 'itemName';
  bool _ascending = true;
  final _scrollController = ScrollController();

  Stream<QuerySnapshot> get _itemsStream {
    return FirebaseFirestore.instance
        .collection('items')
        .where('teamId', isEqualTo: widget.teamId)
        .snapshots();
  }

  List<DocumentSnapshot> _sortItems(List<DocumentSnapshot> items) {
    return items
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        dynamic aValue = aData[_sortBy];
        dynamic bValue = bData[_sortBy];

        if (aValue == null) return _ascending ? -1 : 1;
        if (bValue == null) return _ascending ? 1 : -1;

        int comparison;
        if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }

        return _ascending ? comparison : -comparison;
      });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Barang',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Urutkan:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                _buildSortChip('Nama', 'itemName', Icons.sort_by_alpha),
                _buildSortChip('Harga Jual', 'price', Icons.attach_money),
                _buildSortChip('Harga Beli', 'cost', Icons.money_off),
                _buildSortChip('Kategori', 'category', Icons.category),
                _buildSortChip('Merk', 'brand', Icons.branding_watermark),
                _buildSortChip('Stok', 'stock', Icons.inventory),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _itemsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final sortedDocs = _sortItems(snapshot.data!.docs);
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        sortedDocs[index].data() as Map<String, dynamic>;
                    return _buildItemCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildSortChip(String label, String sortKey, IconData icon) {
    bool isSelected = _sortBy == sortKey;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
            SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600])),
            if (isSelected)
              Icon(
                _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Colors.white,
              ),
          ],
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            if (_sortBy == sortKey) {
              _ascending = !_ascending;
            } else {
              _sortBy = sortKey;
              _ascending = true;
            }
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue,
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['itemName'] ?? 'Unnamed Item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${data['category'] ?? 'No Category'} • ${data['brand'] ?? 'No Brand'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriceColumn('Harga Beli', data['cost'] ?? 0),
                      SizedBox(width: 24),
                      _buildPriceColumn('Harga Jual', data['price'] ?? 0),
                    ],
                  ),
                ],
              ),
            ),
            _buildStockIndicator(data['stock'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceColumn(String label, num price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        Text(
          NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
              .format(price),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStockIndicator(int stock) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Stok',
            style: TextStyle(color: Colors.blue[900], fontSize: 12),
          ),
          Text(
            '$stock',
            style: TextStyle(
              color: Colors.blue[900],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada barang',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan barang pertama Anda',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
