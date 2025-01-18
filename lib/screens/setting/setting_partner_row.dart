import 'package:flutter/material.dart';

class PartnerRow extends StatelessWidget {
  final String title;
  final String value;

  const PartnerRow({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(value),
    );
  }
}
