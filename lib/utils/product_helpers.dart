import 'package:intl/intl.dart';
import '/models/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String formatCurrency(String value) {
  if (value.isEmpty) return '';
  final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  return NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
      .format(number);
}

Future<void> saveItem(Item item) async {
  await FirebaseFirestore.instance.collection('items').add(item.toMap());
}
