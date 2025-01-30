import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/screen/widget/chart-data.dart';
// Import your DatabaseService class here

class QuickStatsScreen extends StatefulWidget {
  @override
  _QuickStatsScreenState createState() => _QuickStatsScreenState();
}

class _QuickStatsScreenState extends State<QuickStatsScreen> {
  late Future<Map<String, dynamic>> _dashboardData;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
var chartData;
  @override
  void initState() {
    super.initState();
    _dashboardData = fetchDashboardData();
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    final dbService = DatabaseService.instance;

    // Fetch today's expenses
    final today = DateTime.now();
    var todayExpenses ;
    final normalizedStartDate = DateTime(today.year, today.month, today.day);
    final normalizedEndDate =  DateTime(today.year, today.month, today.day, 23, 59, 59, 999);

    final allExpenses = await DatabaseService.instance.getAllExpenses();
    setState(() {
      todayExpenses = allExpenses.where((expense) {
        final expenseDate = DateTime.parse(expense.date.toString());
        return expenseDate.isAfter(normalizedStartDate) && expenseDate.isBefore(normalizedEndDate);
      }).toList();
    });

    // Fetch weekly expenses
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final weeklyExpenses = await dbService.getExpensesInRange(startOfWeek, endOfWeek);

    // Fetch monthly expenses
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = DateTime(today.year, today.month + 1, 1).subtract(const Duration(seconds: 1));
    final monthlyExpenses = await dbService.getExpensesInRange(startOfMonth, endOfMonth);

    // Calculate total expenses
    double totalSpentToday = todayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    double totalSpentThisWeek = weeklyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    double totalSpentThisMonth = monthlyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Fetch top categories (label used as category)
    final topCategories = await dbService.getExpensesByCategory(DateTime(today.year, today.month));
     chartData = topCategories.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
    final now = DateTime.now();


  //  DateTime monthDate = DateTime(now.year, now.month);
   // String formattedMonth = DateFormat.yMMMM().format(monthDate);
  //  final month = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //  var cash = await dbService.getSpendingLimit(formattedMonth);

  //  final defaultLimit = await DatabaseService.instance.getSpendingLimit(null);
   // var cash1;
    setState(() {
    //   cash = defaultLimit ?? 0.0;
    });
   // print('object $cash1');
//print(cash);
// Check if cash is null or empty, and set it to 0.0 if so
   // var cashLimits = (cash != null && cash != '') ? cash : 0.0;

// Replace Top Categories section with the Chart
    String formattedMonth = DateFormat('yyyy-MM-dd').format(now);

 var cas = await DatabaseService.instance.getSpendingLimit(null);
    var cashLimits = (cas != null && cas != '') ? cas : 0.0;
    return {
      'totalSpentToday': totalSpentToday,
      'totalSpentThisWeek': totalSpentThisWeek,
      'totalSpentThisMonth': totalSpentThisMonth,
      'topCategories': topCategories,
      'cashLimit': cashLimits,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final totalSpentToday = data['totalSpentToday'] as double;
          final totalSpentThisWeek = data['totalSpentThisWeek'] as double;
          final totalSpentThisMonth = data['totalSpentThisMonth'] as double;
          final topCategories = data['topCategories'] as Map<String, double>;
          final spendingLimit = data['cashLimit'] as double;


         // const double spendingLimit = 5000.0; // Example limit

          return  SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                GridView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: screenWidth / (screenHeight * 0.25),
                  ),
                  children: [
                    _buildStatCard("Today", totalSpentToday, Colors.blue),
                    _buildStatCard("This Week", totalSpentThisWeek, Colors.green),
                    _buildStatCard("This Month", totalSpentThisMonth, Colors.orange),
                    _buildStatCard("Limit", spendingLimit, Colors.red),
                  ],
                ),
                const SizedBox(height: 20),

                // Spending Alert
                if (totalSpentThisMonth > spendingLimit)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "You have exceeded your monthly limit of \$${spendingLimit.toStringAsFixed(2)}!",
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Top Categories
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ChartSummary(data: chartData),
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                "\$${value.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
