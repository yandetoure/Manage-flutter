class Budget {
  final int id;
  final String category;
  final double amount;
  final double spent;
  final double remaining;
  final double percentageUsed;
  final bool isOverBudget;
  final int month;
  final int year;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
    required this.isOverBudget,
    required this.month,
    required this.year,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      amount: double.parse(json['amount'].toString()),
      spent: double.parse(json['spent'].toString()),
      remaining: double.parse(json['remaining'].toString()),
      percentageUsed: double.parse(json['percentage_used'].toString()),
      isOverBudget: json['is_over_budget'] == true,
      month: json['month'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }
}

class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final double percentageUsed;
  final int categoriesCount;
  final int overBudgetCount;

  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.percentageUsed,
    required this.categoriesCount,
    required this.overBudgetCount,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      totalBudget: double.parse(json['total_budget'].toString()),
      totalSpent: double.parse(json['total_spent'].toString()),
      totalRemaining: double.parse(json['total_remaining'].toString()),
      percentageUsed: double.parse(json['percentage_used'].toString()),
      categoriesCount: json['categories_count'],
      overBudgetCount: json['over_budget_count'],
    );
  }
}
