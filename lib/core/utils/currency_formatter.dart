import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}
