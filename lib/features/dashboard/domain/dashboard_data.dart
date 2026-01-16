
class DashboardData {
  final double totalRevenues;
  final double totalExpenses;
  final double totalSavings;
  final double balance;
  final List<TransactionItem> recentTransactions;

  DashboardData({
    required this.totalRevenues,
    required this.totalExpenses,
    required this.totalSavings,
    required this.balance,
    required this.recentTransactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalRevenues: _parseDouble(json['total_revenues']),
      totalExpenses: _parseDouble(json['total_expenses']),
      totalSavings: _parseDouble(json['total_savings']),
      balance: _parseDouble(json['balance']),
      recentTransactions: (json['recent_transactions'] as List?)
          ?.map((e) => TransactionItem.fromJson(e))
          .toList() ?? [],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TransactionItem {
  final int id;
  final double amount;
  final String? description;
  final String date; // keep as string for now or parse
  final String type; // 'revenue' or 'expense'

  TransactionItem({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.type,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      amount: DashboardData._parseDouble(json['amount']),
      description: json['description'],
      date: json['date'] ?? '',
      type: json['type'] ?? 'revenue',
    );
  }
}
