class Expense {
  final int? id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;


  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date, this.category = 'Uncategorized',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category ,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'] ?? 'Uncategorized',
    );
  }
}
