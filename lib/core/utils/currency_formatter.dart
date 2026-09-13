import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = 'TMT'}) {
    final formatter = NumberFormat.currency(
      symbol: '$symbol ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = 'TMT'}) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k $symbol';
    }
    return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 1)} $symbol';
  }
}
