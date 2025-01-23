import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tokokita_app/screens/product/edit_item_page.dart';
import '/models/item_model.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;

  const ItemDetailPage({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Stream<DocumentSnapshot> _itemStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _itemStream = FirebaseFirestore.instance
        .collection('items')
        .doc(widget.item.itemId)
        .snapshots();
  }

  Future<void> _navigateToEdit(Item currentItem) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemPage(item: currentItem),
      ),
    );

    // Jika edit berhasil, refresh stream
    if (result == true && mounted) {
      setState(() {
        _itemStream = FirebaseFirestore.instance
            .collection('items')
            .doc(widget.item.itemId)
            .snapshots();
      });
    }
  }

  Future<void> _deleteItem(BuildContext context, String itemId) async {
    try {
      // Cek stok barang
      final itemDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId)
          .get();

      if (!itemDoc.exists) {
        throw 'Barang tidak ditemukan';
      }

      final itemData = itemDoc.data() as Map<String, dynamic>;
      final currentStock = itemData['stock'] ?? 0;

      // Validasi stok
      if (currentStock > 0) {
        throw 'Tidak dapat menghapus barang karena masih memiliki stok';
      }

      // Cek apakah barang pernah memiliki transaksi
      final transactionSnapshot = await FirebaseFirestore.instance
          .collection('stock_transactions')
          .where('itemId', isEqualTo: itemId)
          .limit(1)
          .get();

      if (transactionSnapshot.docs.isNotEmpty) {
        throw 'Tidak dapat menghapus barang karena memiliki riwayat transaksi';
      }

      // Jika lolos semua validasi, baru bisa dihapus
      await FirebaseFirestore.instance.collection('items').doc(itemId).delete();

      if (context.mounted) {
        // Kembali ke HomeScreen
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'userId': widget.item.teamId, // sesuaikan dengan kebutuhan
            'teamId': widget.item.teamId,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: const Text('Barang hanya bisa dihapus jika:\n'
            '• Tidak memiliki stok\n'
            '• Belum pernah memiliki transaksi\n\n'
            'Yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(context, widget.item.itemId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Edit Button
          StreamBuilder<DocumentSnapshot>(
            stream: _itemStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              // Tambahkan pengecekan exists
              if (!snapshot.data!.exists) return const SizedBox();

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final updatedItem = Item.fromMap(data, widget.item.itemId);

              return Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.edit_outlined, color: Colors.black87),
                    onPressed: () => _navigateToEdit(updatedItem),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.black87),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _itemStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Barang tidak ditemukan'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final updatedItem = Item.fromMap(data, widget.item.itemId);

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Informasi Barang Section
                  _buildSection(
                    'Informasi Barang',
                    [
                      _buildInfoField('ID Barang', updatedItem.itemId),
                      _buildInfoField('Nama Barang', updatedItem.itemName),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Atribut Section
                  _buildSection(
                    'Atribut',
                    [
                      _buildInfoField('Kategori', updatedItem.category),
                      _buildInfoField('Merk', updatedItem.brand),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Harga Section
                  _buildSection(
                    'Harga',
                    [
                      _buildInfoField(
                        'Harga Beli',
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(updatedItem.cost),
                      ),
                      _buildInfoField(
                        'Harga Jual',
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(updatedItem.price),
                      ),
                    ],
                  ),

                  // Spacer untuk bottom card
                  const SizedBox(height: 100),
                ],
              ),

              // Bottom Stock Card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stok Tersedia',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${updatedItem.stock ?? 0} unit',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to stock adjustment page
                        },
                        icon: const Icon(Icons.swap_vert),
                        label: const Text('Stok Keluar/Masuk'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
