class SavingsGoal {
  final int? id;
  final String name;
  final double goal_amount;
  final double amount_saved;
  final DateTime startDate;
  final DateTime endDate;

  SavingsGoal({
    this.id,
    required this.name,
    required this.goal_amount,
    required this.amount_saved,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': name,
      'goal_amount': goal_amount,
      'amount_saved': goal_amount,
      'date_created': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  static SavingsGoal fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['description'],
      goal_amount: map['goal_amount'],
      amount_saved: map['amount_saved'],
      startDate: DateTime.parse(map['date_created']),
      endDate: DateTime.parse(map['end_date']),
    );
  }
}