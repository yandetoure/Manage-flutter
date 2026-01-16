class Claim {
  final int id;
  final double amount;
  final String debtor;
  final String? description;
  final String? dueDate;
  final String status;
  final double totalPaid;
  final double remaining;

  Claim({
    required this.id,
    required this.amount,
    required this.debtor,
    this.description,
    this.dueDate,
    required this.status,
    this.totalPaid = 0.0,
    this.remaining = 0.0,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'],
      amount: _parseDouble(json['amount']),
      debtor: json['debtor'] ?? 'Inconnu',
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
