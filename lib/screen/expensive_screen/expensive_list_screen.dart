/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/model/expens_modle.dart';
import 'package:my_expense/utils/colors_utils.dart';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minAmountController = TextEditingController();
  final TextEditingController maxAmountController = TextEditingController();

  List<Expense> filteredExpenses = [];
  List<Expense> allExpenses = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailyExpenses(); // Load today's expenses by default
  }

  Future<void> _loadDailyExpenses() async {
    final today = DateTime.now();
    await _filterExpensesByDate(today, today);
  }

  Future<void> _filterExpensesByDate(DateTime startDate, DateTime endDate) async {
    final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    allExpenses = await DatabaseService.instance.getAllExpenses();
    setState(() {
      filteredExpenses = allExpenses.where((expense) {
        final expenseDate = DateTime.parse(expense.date.toString());
        return expenseDate.isAfter(normalizedStartDate) && expenseDate.isBefore(normalizedEndDate);
      }).toList();
    });
  }

  void _searchExpenses() {
    final query = searchController.text.toLowerCase();
    final minAmount = double.tryParse(minAmountController.text) ?? 0;
    final maxAmount = double.tryParse(maxAmountController.text) ?? double.infinity;

    setState(() {
      filteredExpenses = allExpenses.where((expense) {
        final matchesCategory = expense.category.toLowerCase().contains(query);
        final matchesAmount = expense.amount >= minAmount && expense.amount <= maxAmount;
        return matchesCategory && matchesAmount;
      }).toList();
    });
  }

  // Custom Card widget to display each expense
  Widget _expenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Category
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 28,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    expense.category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Amount
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 28,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 10),
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  softWrap: true,

                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 28,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    expense.description,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 28,
                  color: Colors.purple.shade700,
                ),
                const SizedBox(width: 10),
                Text(
                  'Date: ${expense.date}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Text('Select the  date range to have your expenses and click on search',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),),
            ),
            const SizedBox(height: 5),
            // Date Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startDateController,
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    readOnly: true,
                    onTap: () async => _selectStartDate(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: endDateController,
                    decoration: const InputDecoration(labelText: 'End Date'),
                    readOnly: true,
                    onTap: () async => _selectEndDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text('Filter by :',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),),
            ),
            // Search Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: minAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Amount',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: maxAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Amount',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Filter & Search Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (startDateController.text.isEmpty || endDateController.text.isEmpty) {
                      Get.snackbar('Error', 'Please select both start and end dates',
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    _filterExpensesByDate(startDate, endDate);
                  },
                  child: const Text('Search'),
                ),
                ElevatedButton(
                  onPressed: _searchExpenses,
                  child: const Text('Filter by Date'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Expense List
            Expanded(
              child: filteredExpenses.isEmpty
                  ? const Center(child: Text('No expenses found!'))
                  : ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  return _expenseCard(expense);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? startDate;

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        startDateController.text = '${startDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? endDate;

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        endDateController.text = '${endDate.toLocal()}'.split(' ')[0];
      });
    }
  }
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/model/expens_modle.dart';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minAmountController = TextEditingController();
  final TextEditingController maxAmountController = TextEditingController();

  List<Expense> filteredExpenses = [];
  List<Expense> allExpenses = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailyExpenses();
  }

  Future<void> _loadDailyExpenses() async {
    final today = DateTime.now();
    await _filterExpensesByDate(today, today);
  }

  Future<void> _filterExpensesByDate(DateTime startDate, DateTime endDate) async {
    final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    allExpenses = await DatabaseService.instance.getAllExpenses();
    setState(() {
      filteredExpenses = allExpenses.where((expense) {
        final expenseDate = DateTime.parse(expense.date.toString());
        return expenseDate.isAfter(normalizedStartDate) && expenseDate.isBefore(normalizedEndDate);
      }).toList();
    });
  }


  void _searchExpenses() {
    final query = searchController.text.toLowerCase();
    final minAmount = double.tryParse(minAmountController.text) ?? 0;
    final maxAmount = double.tryParse(maxAmountController.text) ?? double.infinity;

    setState(() {
      filteredExpenses = allExpenses.where((expense) {
        final matchesCategory = expense.category.toLowerCase().contains(query);
        final matchesAmount = expense.amount >= minAmount && expense.amount <= maxAmount;
        return matchesCategory && matchesAmount;
      }).toList();
    });
  }

  Widget _expenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Icon(Icons.category, color: Colors.blue.shade700),
        title: Text(
          expense.category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('Date: ${expense.date}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade700),
          onPressed: () {
            // Add delete functionality here
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDailyExpenses,
          ),
        ],
      ),
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Filter Expenses",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startDateController,
                              decoration: const InputDecoration(labelText: 'Start Date'),
                              readOnly: true,
                              onTap: () async => _selectStartDate(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: endDateController,
                              decoration: const InputDecoration(labelText: 'End Date'),
                              readOnly: true,
                              onTap: () async => _selectEndDate(context),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(labelText: 'Category'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: minAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Min Amount'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: maxAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Max Amount'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              filteredExpenses.isEmpty
                  ? Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No expenses found!'),
                    ],
                  ),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    return _expenseCard(filteredExpenses[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? startDate;

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        startDateController.text = '${startDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? endDate;

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        endDateController.text = '${endDate.toLocal()}'.split(' ')[0];
        _searchExpenses();
      });

    }
  }
}
