import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(amount);
      case 'USD':
        return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(amount);
      case 'FCFA':
      default:
        return NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0).format(amount);
    }
  }

  static String getSymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'FCFA':
      default:
        return 'FCFA';
    }
  }
}
