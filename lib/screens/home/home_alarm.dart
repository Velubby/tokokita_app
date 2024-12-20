import 'package:tokokita_app/screens/home/home_common/row_render_container.dart';
import 'package:flutter/material.dart';

class HomeAlarm extends StatelessWidget {
  const HomeAlarm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notifikasi stok rendah',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
        RowRenderContainer(
            assetsSvg: 'check.svg',
            title: 'Periksa stok rendah',
            msg: 'Periksa stok rendah'),
      ],
    );
  }
}
