import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tambahkan jenis barang",
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildInputField("ID Barang", idBarangController),
              buildInputField("Nama Barang", namaBarangController),
              buildInputField("Kategori", kategoriController),
              buildInputField("Merk", merkController),
              buildInputField("Harga Beli", hargaBeliController,
                  isNumber: true),
              buildInputField("Harga Jual", hargaJualController,
                  isNumber: true),
              SizedBox(height: 20),
              // Tombol Simpan
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
