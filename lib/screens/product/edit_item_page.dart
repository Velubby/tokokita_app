import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokokita_app/screens/home/add_in_out/brand_page.dart';
import 'package:tokokita_app/screens/home/add_in_out/category_page.dart';
import '/models/item_model.dart';

class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaBarangController;
  late TextEditingController _kategoriController;
  late TextEditingController _merkController;
  late TextEditingController _hargaJualController;
  late TextEditingController _hargaBeliController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _namaBarangController = TextEditingController(text: widget.item.itemName);
    _kategoriController = TextEditingController(text: widget.item.category);
    _merkController = TextEditingController(text: widget.item.brand);
    _hargaJualController = TextEditingController(
      text: NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(widget.item.price),
    );
    _hargaBeliController = TextEditingController(
      text: NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(widget.item.cost),
    );
    _stockController = TextEditingController(
      text: (widget.item.stock ?? 0).toString(),
    );
  }

  double _parseCurrency(String value) {
    final numericValue = value
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(numericValue) ?? 0.0;
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return '';
    final number = double.tryParse(value) ?? 0;
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(number);
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update data
      await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.item.itemId)
          .update({
        'itemName': _namaBarangController.text.trim(),
        'category': _kategoriController.text.trim(),
        'brand': _merkController.text.trim(),
        'price': _parseCurrency(_hargaJualController.text),
        'cost': _parseCurrency(_hargaBeliController.text),
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
      });

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);
      // Return to previous page
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog if error occurs
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Barang',
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ID Barang (Read-only)
            TextFormField(
              initialValue: widget.item.itemId,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'ID Barang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            const SizedBox(height: 16),

            // Nama Barang
            TextFormField(
              controller: _namaBarangController,
              decoration: InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) => value?.trim().isEmpty == true
                  ? 'Nama barang harus diisi'
                  : null,
            ),

            const SizedBox(height: 24),

            // Atribut Section
            Text(
              'Atribut',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Kategori
            GestureDetector(
              onTap: () async {
                final selectedValue = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryPage(teamId: widget.item.teamId),
                  ),
                );
                if (selectedValue != null) {
                  setState(() => _kategoriController.text = selectedValue);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _kategoriController,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Kategori harus dipilih' : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Merk
            GestureDetector(
              onTap: () async {
                final selectedValue = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrandPage(teamId: widget.item.teamId),
                  ),
                );
                if (selectedValue != null) {
                  setState(() => _merkController.text = selectedValue);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _merkController,
                  decoration: InputDecoration(
                    labelText: 'Merk',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Merk harus dipilih' : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Harga Section
            Text(
              'Harga',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Harga Beli
            TextFormField(
              controller: _hargaBeliController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Beli',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                final newValue = _formatCurrency(value);
                _hargaBeliController.value = TextEditingValue(
                  text: newValue,
                  selection: TextSelection.collapsed(offset: newValue.length),
                );
              },
              validator: (value) {
                if (value?.isEmpty == true) return 'Harga beli harus diisi';
                if (_parseCurrency(value!) <= 0) {
                  return 'Harga beli harus lebih dari 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Harga Jual
            TextFormField(
              controller: _hargaJualController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Jual',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                final newValue = _formatCurrency(value);
                _hargaJualController.value = TextEditingValue(
                  text: newValue,
                  selection: TextSelection.collapsed(offset: newValue.length),
                );
              },
              validator: (value) {
                if (value?.isEmpty == true) return 'Harga jual harus diisi';
                if (_parseCurrency(value!) <= 0) {
                  return 'Harga jual harus lebih dari 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Stok
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty == true) return 'Stok harus diisi';
                final stock = int.tryParse(value!);
                if (stock == null) return 'Stok harus berupa angka';
                if (stock < 0) return 'Stok tidak boleh negatif';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Update Button
            ElevatedButton(
              onPressed: _updateItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _kategoriController.dispose();
    _merkController.dispose();
    _hargaJualController.dispose();
    _hargaBeliController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
