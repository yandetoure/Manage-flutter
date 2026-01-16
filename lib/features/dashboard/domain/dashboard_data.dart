
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
      totalRevenues: (json['total_revenues'] ?? 0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      totalSavings: (json['total_savings'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      recentTransactions: (json['recent_transactions'] as List?)
          ?.map((e) => TransactionItem.fromJson(e))
          .toList() ?? [],
    );
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
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      date: json['date'] ?? '',
      type: json['type'] ?? 'revenue',
    );
  }
}
