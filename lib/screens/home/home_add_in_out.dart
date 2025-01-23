import 'package:tokokita_app/screens/home/home_common/row_render_container.dart';
import 'package:tokokita_app/screens/home/add_in_out/add_product_page.dart';
import 'package:tokokita_app/screens/home/add_in_out/stock_in_page.dart';
import 'package:tokokita_app/screens/home/add_in_out/stock_out_page.dart';
import 'package:flutter/material.dart';

class HomeAddInOut extends StatelessWidget {
  const HomeAddInOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu Utama',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
        RowRenderContainer(
          assetsSvg: 'barcode.svg',
          title: 'Tambah Barang',
          msg: 'Tambah Barang',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductPage()),
            );
          },
        ),
        RowRenderContainer(
          assetsSvg: 'in.svg',
          title: 'Masuk',
          msg: 'Masuk',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StockInPage()),
            );
          },
        ),
        RowRenderContainer(
          assetsSvg: 'out.svg',
          title: 'Keluar',
          msg: 'Keluar',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StockOutPage()),
            );
          },
        ),
      ],
    );
  }
}
