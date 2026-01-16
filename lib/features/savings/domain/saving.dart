
class Saving {
  final int id;
  final double currentAmount;
  final double targetAmount;
  final String targetName;
  final String? deadline;
  final String? description;

  Saving({
    required this.id,
    required this.currentAmount,
    required this.targetAmount,
    required this.targetName,
    this.deadline,
    this.description,
  });

  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'],
      currentAmount: _parseDouble(json['current_amount']),
      targetAmount: _parseDouble(json['target_amount']),
      targetName: json['target_name'] ?? 'Épargne',
      deadline: json['deadline'],
      description: json['description'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
