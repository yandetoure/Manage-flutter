class Debt {
  final int id;
  final double amount;
  final String creditor;
  final String? description;
  final String? dueDate;
  final String status;
  final double totalPaid;
  final double remaining;

  Debt({
    required this.id,
    required this.amount,
    required this.creditor,
    this.description,
    this.dueDate,
    required this.status,
    this.totalPaid = 0.0,
    this.remaining = 0.0,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      amount: _parseDouble(json['amount']),
      creditor: json['creditor'] ?? 'Inconnu',
      description: json['description'],
      dueDate: json['due_date'],
      status: json['status'] ?? 'pending',
      totalPaid: _parseDouble(json['total_paid']),
      remaining: _parseDouble(json['remaining']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
