/*
import 'package:flutter/material.dart';
import 'package:my_expense/database/database_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  @override
  _MonthlyReportScreenState createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  Map<String, double> categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadMonthlyExpenses();
  }

  Future<void> _loadMonthlyExpenses() async {
    try {
      final expenses = await DatabaseService.instance.getExpensesByCategory(DateTime.now());
      setState(() {
        categoryExpenses = expenses;
      });
    } catch (e) {
      print('Error loading monthly expenses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Summary'),
      ),
      body: categoryExpenses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Spending by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
         */
/*   Container(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: categoryExpenses.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.key}\n\$${entry.value.toStringAsFixed(1)}',
                      color: _getCategoryColor(entry.key),
                      radius: 100,
                      titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),*//*

          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Transport':
        return Colors.blue;
      case 'Entertainment':
        return Colors.orange;
      case 'Bills':
        return Colors.red;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:my_expense/database/database_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  @override
  _MonthlyReportScreenState createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  Map<String, double> _categoryExpenses = {};
  double _totalSpent = 0.0;
  double _averageSpent = 0.0;
  double _highestExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final categoryExpenses = await DatabaseService.instance.getExpensesByCategory(DateTime.now());
    final totalSpent = categoryExpenses.values.fold(0.0, (a, b) => a + b);
    final highestExpense = categoryExpenses.values.isNotEmpty
        ? categoryExpenses.values.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    setState(() {
      _categoryExpenses = categoryExpenses;
      _totalSpent = totalSpent;
      _highestExpense = highestExpense;
      _averageSpent = totalSpent / daysInMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),
      body: _categoryExpenses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Total Spent: \$${_totalSpent.toStringAsFixed(2)}'),
            Text('Average Daily Spending: \$${_averageSpent.toStringAsFixed(2)}'),
            Text('Highest Expense: \$${_highestExpense.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            const Text(
              'Expense Categories (Pie Chart)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: charts.PieChart(
                [
                  charts.Series<MapEntry<String, double>, String>(
                    id: 'Categories',
                    domainFn: (entry, _) => entry.key,
                    measureFn: (entry, _) => entry.value,
                    data: _categoryExpenses.entries.toList(),
                    labelAccessorFn: (entry, _) =>
                    '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                  )
                ],
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


