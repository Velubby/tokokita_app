import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/utils/id_generator.dart';
import 'category_page.dart';
import 'brand_page.dart';
import '/models/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokokita_app/services/team_selection_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Controllers
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _idBarangController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _hargaBeliController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  // Services
  final TeamSelectionService _teamSelectionService = TeamSelectionService();

  // State variables
  String? _teamId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // Generate initial ID
    _idBarangController.text = IDGenerator.generateID();

    // Fetch team ID
    final teamDetails = await _teamSelectionService.getSelectedTeam();
    setState(() {
      _teamId = teamDetails['teamId'];
    });
  }

  // Currency and ID formatting methods
  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
        .format(number);
  }

  void _regenerateID() {
    setState(() {
      _idBarangController.text = IDGenerator.generateID();
    });
  }

  // Save item method
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      if (_teamId == null) {
        _showErrorSnackBar('Team ID tidak ditemukan!');
        return;
      }

      try {
        final item = Item(
          itemId: _idBarangController.text,
          teamId: _teamId!,
          itemName: _namaBarangController.text,
          category: _kategoriController.text,
          brand: _merkController.text,
          price: double.tryParse(_hargaJualController.text
                  .replaceAll(RegExp(r'[^0-9]'), '')) ??
              0.0,
          cost: double.tryParse(_hargaBeliController.text
                  .replaceAll(RegExp(r'[^0-9]'), '')) ??
              0.0,
          stock: int.tryParse(_stockController.text) ?? 0,
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance.collection('items').add(item.toMap());

        _showSuccessSnackBar('Barang berhasil disimpan!');
        _clearForm();
      } catch (e) {
        _showErrorSnackBar('Gagal menyimpan barang: $e');
      }
    }
  }

  // Clear form method
  void _clearForm() {
    _namaBarangController.clear();
    _kategoriController.clear();
    _merkController.clear();
    _hargaJualController.clear();
    _hargaBeliController.clear();
    _stockController.clear();
    _idBarangController.text = IDGenerator.generateID();
  }

  // SnackBar methods
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Tambah Barang Baru",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ID Section
            _buildIDAndNameSection(),

            const SizedBox(height: 20),

            // Attributes Section
            _buildAttributesSection(),

            const SizedBox(height: 20),

            // Price Section
            _buildPriceSection(),

            const SizedBox(height: 30),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIDAndNameSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: _idBarangController,
                label: 'ID Barang',
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'ID tidak boleh kosong' : null,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue),
              onPressed: _regenerateID,
              tooltip: 'Generate New ID',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextFormField(
          controller: _namaBarangController,
          label: 'Nama Barang',
          validator: (value) =>
              value!.isEmpty ? 'Nama barang harus diisi' : null,
        ),
      ],
    );
  }

  Widget _buildAttributesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atribut',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        _buildSelectableField(
          controller: _kategoriController,
          label: 'Kategori',
          page: CategoryPage(teamId: _teamId ?? 'defaultTeamId'),
        ),
        _buildSelectableField(
          controller: _merkController,
          label: 'Merk',
          page: BrandPage(teamId: _teamId ?? 'defaultTeamId'),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Harga',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        _buildCurrencyField(
          controller: _hargaBeliController,
          label: 'Harga Beli',
        ),
        _buildCurrencyField(
          controller: _hargaJualController,
          label: 'Harga Jual',
        ),
        _buildTextFormField(
          controller: _stockController,
          label: 'Stok',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Stok harus diisi' : null,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveItem,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'Simpan Barang',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          controller.value = TextEditingValue(
            text: _formatCurrency(value),
            selection: TextSelection.collapsed(
              offset: _formatCurrency(value).length,
            ),
          );
        },
        validator: (value) => value!.isEmpty ? '$label harus diisi' : null,
      ),
    );
  }

  Widget _buildSelectableField({
    required TextEditingController controller,
    required String label,
    required Widget page,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          final selectedValue = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
          if (selectedValue != null) {
            setState(() {
              controller.text = selectedValue;
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: Icon(Icons.search),
            ),
            validator: (value) =>
                value!.isEmpty ? '$label harus dipilih' : null,
          ),
        ),
      ),
    );
  }
}
