class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });
}

class CurrencyData {
  static final List<Currency> commonCurrencies = [
    Currency(code: 'FCFA', name: 'Franc CFA (BCEAO)', symbol: 'FCFA', flag: '🇸🇳'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    Currency(code: 'USD', name: 'Dollar américain', symbol: '\$', flag: '🇺🇸'),
    Currency(code: 'GBP', name: 'Livre sterling', symbol: '£', flag: '🇬🇧'),
    Currency(code: 'CAD', name: 'Dollar canadien', symbol: 'CA\$', flag: '🇨🇦'),
    Currency(code: 'CHF', name: 'Franc suisse', symbol: 'CHF', flag: '🇨🇭'),
    Currency(code: 'MAD', name: 'Dirham marocain', symbol: 'DH', flag: '🇲🇦'),
    Currency(code: 'JPY', name: 'Yen japonais', symbol: '¥', flag: '🇯🇵'),
    Currency(code: 'CNY', name: 'Yuan chinois', symbol: '¥', flag: '🇨🇳'),
    Currency(code: 'AUD', name: 'Dollar australien', symbol: 'A\$', flag: '🇦🇺'),
    Currency(code: 'NGN', name: 'Naira nigérian', symbol: '₦', flag: '🇳🇬'),
    Currency(code: 'ZAR', name: 'Rand sud-africain', symbol: 'R', flag: '🇿🇦'),
    Currency(code: 'AED', name: 'Dirham des EAU', symbol: 'د.إ', flag: '🇦🇪'),
    Currency(code: 'BRL', name: 'Real brésilien', symbol: 'R\$', flag: '🇧🇷'),
    Currency(code: 'INR', name: 'Roupie indienne', symbol: '₹', flag: '🇮🇳'),
  ];

  static Currency? getCurrency(String code) {
    try {
      return commonCurrencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }
}
