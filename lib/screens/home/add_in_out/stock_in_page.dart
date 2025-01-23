import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/item_model.dart';
import '/models/stock_transaction_model.dart';
import '/services/team_selection_service.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});

  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _supplierController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();

  String? _teamId;
  String? _selectedSupplierId;
  Item? _selectedItem;
  bool _isLoading = false;

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

  Future<void> _selectItem() async {
    if (_teamId == null) return;

    final snapshot = await showDialog<DocumentSnapshot>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Barang'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('teamId', isEqualTo: _teamId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data?.docs ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('Tidak ada barang'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final data = item.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['itemName'] ?? ''),
                    subtitle: Text('Stok: ${data['stock'] ?? 0}'),
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    if (snapshot != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _itemController.text = data['itemName'] ?? '';
        _selectedItem = Item.fromMap(data, snapshot.id);
      });
    }
  }

  Future<void> _selectSupplier() async {
    if (_teamId == null) return;

    final snapshot = await showDialog<DocumentSnapshot>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Supplier'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('suppliers')
                .where('teamId', isEqualTo: _teamId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final suppliers = snapshot.data?.docs ?? [];
              if (suppliers.isEmpty) {
                return const Center(child: Text('Tidak ada supplier'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  final data = supplier.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['name'] ?? ''),
                    onTap: () => Navigator.pop(context, supplier),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    if (snapshot != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _selectedSupplierId = snapshot.id;
        _supplierController.text = data['name'] ?? '';
      });
    }
  }

  Future<void> _saveStockIn() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedItem == null || _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih barang dan supplier terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final int quantity = int.parse(_jumlahController.text);
      final int currentStock = _selectedItem!.stock ?? 0;
      final int newStock = currentStock + quantity;

      // Update stock in items collection
      await FirebaseFirestore.instance
          .collection('items')
          .doc(_selectedItem!.itemId)
          .update({'stock': newStock});

      // Create stock transaction
      final stockTransaction = StockTransaction(
        transactionId: '',
        teamId: _teamId!,
        type: 'In',
        itemId: _selectedItem!.itemId,
        itemName: _selectedItem!.itemName,
        quantity: quantity,
        supplierName: _supplierController.text,
        customerName: null,
        createdAt: DateTime.now(),
      );

      // Add to stock_transactions collection
      await FirebaseFirestore.instance
          .collection('stock_transactions')
          .add(stockTransaction.toMap());

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok masuk berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Stok Masuk",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Stok Masuk",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.green.shade400,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pilih Barang
            GestureDetector(
              onTap: _selectItem,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    labelText: 'Pilih Barang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Barang harus dipilih' : null,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pilih Supplier
            GestureDetector(
              onTap: _selectSupplier,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _supplierController,
                  decoration: InputDecoration(
                    labelText: 'Pilih Supplier',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Supplier harus dipilih' : null,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Jumlah
            TextFormField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty == true) return 'Jumlah harus diisi';
                final number = int.tryParse(value!);
                if (number == null) return 'Jumlah harus berupa angka';
                if (number <= 0) return 'Jumlah harus lebih dari 0';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Catatan
            TextFormField(
              controller: _catatanController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveStockIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan',
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
    _itemController.dispose();
    _supplierController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }
}
