import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '/models/item_model.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;

  const ItemDetailPage({
    Key? key,
    required this.item,
  }) : super(key: key);

  Future<void> _deleteItem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: const Text('Yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(item.itemId)
            .delete();

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barang berhasil dihapus')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () {
              // Navigate to edit page
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: () => _deleteItem(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ID Section
              _buildSection(
                context,
                'Informasi Barang',
                [
                  _buildReadOnlyField(
                    label: 'ID Barang',
                    value: item.itemId,
                  ),
                  _buildReadOnlyField(
                    label: 'Nama Barang',
                    value: item.itemName,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Attributes Section
              _buildSection(
                context,
                'Atribut',
                [
                  _buildReadOnlyField(
                    label: 'Kategori',
                    value: item.category,
                  ),
                  _buildReadOnlyField(
                    label: 'Merk',
                    value: item.brand,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Price Section
              _buildSection(
                context,
                'Harga',
                [
                  _buildReadOnlyField(
                    label: 'Harga Beli',
                    value: NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(item.cost),
                  ),
                  _buildReadOnlyField(
                    label: 'Harga Jual',
                    value: NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(item.price),
                  ),
                ],
              ),

              // Spacer untuk stock card
              const SizedBox(height: 100),
            ],
          ),

          // Stock Card - Fixed at bottom
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                            '${item.stock ?? 0} unit',
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
                          // Navigate to stock in/out page
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
