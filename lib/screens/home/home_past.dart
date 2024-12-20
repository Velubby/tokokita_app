import 'package:tokokita_app/screens/home/home_common/row_render_container.dart';
import 'package:flutter/material.dart';

class HomePast extends StatelessWidget {
  const HomePast({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Histori kuantitas lalu',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
        RowRenderContainer(
            assetsSvg: 'past.svg',
            title: 'Periksa kuantitas produk sebelumnya',
            msg: 'Periksa kuantitas produk sebelumnya'),
      ],
    );
  }
}
