import 'package:tokokita_app/screens/home/home_common/row_render_container.dart';
import 'package:flutter/material.dart';

class HomeInAndOut extends StatelessWidget {
  const HomeInAndOut({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Masuk / Keluar',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
        RowRenderContainer(
            assetsSvg: 'barcode.svg',
            title: 'Tambah Barang',
            msg: 'Tambah Barang'),
        RowRenderContainer(assetsSvg: 'in.svg', title: 'Masuk', msg: 'Masuk'),
        RowRenderContainer(
            assetsSvg: 'out.svg', title: 'Keluar', msg: 'Keluar'),
      ],
    );
  }
}
