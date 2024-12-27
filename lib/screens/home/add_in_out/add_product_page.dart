import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/utils/id_generator.dart'; // Ensure correct import for IDGenerator
import 'category_page.dart';
import 'brand_page.dart';
import '/models/item_model.dart'; // Ensure this points to the correct path for Item class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController merkController = TextEditingController();
  final TextEditingController idBarangController = TextEditingController();
  final TextEditingController hargaJualController = TextEditingController();
  final TextEditingController hargaBeliController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  String? teamId; // Variable to hold the teamId

  @override
  void initState() {
    super.initState();
    idBarangController.text = IDGenerator.generateID();
    fetchTeamId(); // Fetch teamId on page load
  }

  // Fetch teamId from current user's Firebase document
  void fetchTeamId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          teamId = userDoc[
              'teamId']; // Assuming 'teamId' is stored in the user document
        });
      }
    }
  }

  void regenerateID() {
    setState(() {
      idBarangController.text = IDGenerator.generateID();
    });
  }

  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
        .format(number);
  }

  void saveItem() async {
    if (teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team ID tidak ditemukan!')),
      );
      return;
    }

    final item = Item(
      itemId: idBarangController.text,
      teamId: teamId!, // Passing the teamId
      itemName: namaBarangController.text,
      category: kategoriController.text, // Category from user input
      brand: merkController.text, // Brand from user input
      price: double.tryParse(
              hargaJualController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0.0,
      cost: double.tryParse(
              hargaBeliController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0.0,
      stock: int.tryParse(stockController.text), // Stock from user input
      createdAt: DateTime.now(), // Use current timestamp as creation date
    );

    await FirebaseFirestore.instance
        .collection('items') // Save to 'items' collection instead of 'products'
        .add(item.toMap());
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil disimpan!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Tambah Barang Baru",
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              renderIDField("ID Barang", idBarangController),
              const SizedBox(height: 10),
              renderInputField("Nama Barang", namaBarangController),
              const Divider(
                color: Color.fromARGB(255, 197, 197, 197),
                thickness: 5,
                height: 50,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Atribut",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              renderSelectableField("Kategori", kategoriController,
                  CategoryPage(teamId: teamId ?? 'defaultTeamId')),
              renderSelectableField("Merk", merkController,
                  BrandPage(teamId: teamId ?? 'defaultTeamId')),
              const SizedBox(height: 10),
              const Divider(
                color: Color.fromARGB(255, 197, 197, 197),
                thickness: 5,
                height: 50,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Harga",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              renderInputField("Harga Beli", hargaBeliController,
                  isNumber: true, formatCurrencyInput: true),
              renderInputField("Harga Jual", hargaJualController,
                  isNumber: true, formatCurrencyInput: true),
              renderInputField("Stok", stockController, isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Simpan',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderIDField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: renderInputField(label, controller, readOnly: true),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_outlined, color: Colors.greenAccent),
          onPressed: regenerateID,
        ),
      ],
    );
  }

  Widget renderInputField(String label, TextEditingController controller,
      {bool isNumber = false,
      bool formatCurrencyInput = false,
      bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: formatCurrencyInput
            ? (value) {
                controller.value = TextEditingValue(
                  text: formatCurrency(value),
                  selection: TextSelection.collapsed(
                      offset: formatCurrency(value).length),
                );
              }
            : null,
      ),
    );
  }

  Widget renderSelectableField(
      String label, TextEditingController controller, Widget page) {
    return GestureDetector(
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
        child: renderInputField(label, controller, readOnly: true),
      ),
    );
  }
}
