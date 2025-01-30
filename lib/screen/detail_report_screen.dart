import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/model/expens_modle.dart';

class DetailedReportScreen extends StatelessWidget {
  final DateTime reportMonth;

  const DetailedReportScreen({Key? key, required this.reportMonth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime(reportMonth.year, reportMonth.month, 1);
    final endDate = DateTime(reportMonth.year, reportMonth.month + 1, 1)
        .subtract(const Duration(seconds: 1));

    return Scaffold(
      appBar: AppBar(
        title: Text('Report for ${DateFormat('MMMM yyyy').format(reportMonth)}'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Expense>>(
        future: DatabaseService.instance.getExpensesInRange(startDate, endDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No expenses found for this month.'));
          }

          final expenses = snapshot.data!;
          final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Spent: \$${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseCard(expense: expense);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  const ExpenseCard({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatting the date
    final formattedDate = DateFormat('yyyy-MM-dd').format(expense.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label and Description Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.money,
                    color: _getExpenseColor(expense.category),
                    size: 40,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.category,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date and Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getExpenseColor(expense.category),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get color based on the expense type/label
  Color _getExpenseColor(String label) {
    switch (label.toLowerCase()) {
      case 'transport':
        return Colors.orange;
      case 'food':
        return Colors.green;
      case 'shopping':
        return Colors.blue;
      case 'entertainment':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
