import 'package:intl/intl.dart';

class FormatHelper {
  static String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
        .format(number);
  }
}
