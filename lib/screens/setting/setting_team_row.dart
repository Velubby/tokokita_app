import 'package:flutter/material.dart';

class TeamRow extends StatelessWidget {
  final String title;
  final String value;

  const TeamRow({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
