
class Transaction {
  final int id;
  final double amount;
  final String? description;
  final String date;
  final String type; // 'revenue' or 'expense'
  final String? category; // Only for expense
  final String? source; // Only for revenue

  Transaction({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.type,
    this.category,
    this.source,
  });

  factory Transaction.fromJson(Map<String, dynamic> json, String type) {
    return Transaction(
      id: json['id'],
      amount: _parseDouble(json['amount']),
      description: json['description'],
      date: json['date'] ?? json['created_at'] ?? '', // Fallback
      type: type,
      category: json['category'],
      source: json['source'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
