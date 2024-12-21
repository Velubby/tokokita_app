import 'package:flutter/material.dart';

class OutPage extends StatefulWidget {
  const OutPage({super.key});

  @override
  State<OutPage> createState() => _OutPageState();
}

class _OutPageState extends State<OutPage> {
  final TextEditingController namaCustomerControler = TextEditingController();
  final TextEditingController idbarangController = TextEditingController();
  final TextEditingController jumlahBarangController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tambah Stok Keluar",
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 75,
              ),
              Text(
                "Stok Keluar",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                height: 2,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 20),
              formtambahstok("Nama Customer", namaCustomerControler),
              formtambahstok("ID Barang", idbarangController, isNumber: true),
              formtambahstok("Jumlah Barang", jumlahBarangController,
                  isNumber: true),
              formtambahstok("Catatan", catatanController),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  child: Text(
                    "Simpan",
                    style: TextStyle(fontSize: 16),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget formtambahstok(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )),
      ),
    );
  }
}
