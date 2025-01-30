import 'package:my_expense/model/expens_modle.dart';
import 'package:my_expense/model/saving_goal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._privateConstructor();
  static Database? _database;

  DatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'expense_manager.db'),
      version: 3, // Incremented version to include the 'category' column
      onCreate: (db, version) async {
        // Initial database creation
        await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT,
          amount REAL,
          date TEXT,
          category TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE config (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE categories (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         name TEXT UNIQUE NOT NULL
        )
      ''');
        await db.execute('''
              CREATE TABLE spending_limits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              month TEXT, -- Store month as 'YYYY-MM-01' format
              limit_amount REAL NOT NULL,
              is_recurring INTEGER DEFAULT 1,
              state TEXT  -- Default or monthly limit 
    )
  ''');

        await db.execute('''
  CREATE TABLE savings_goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT NOT NULL,
    goal_amount REAL NOT NULL, -- Total goal amount
    amount_saved REAL NOT NULL DEFAULT 0, -- Total amount saved so far
    date_created TEXT NOT NULL,
    end_date TEXT NOT NULL -- Deadline for the goal
  )
''');
               await db.execute('''
  CREATE TABLE month_savings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    month_year TEXT NOT NULL, -- Format: "YYYY-MM"
    total_expenses REAL NOT NULL, -- Total expenses
    spending_limit REAL NOT NULL , -- spending limit
    savings REAL NOT NULL
  )
''');

      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the 'config' table in version 2
          await db.execute('''
          CREATE TABLE config (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
        }
        if (oldVersion < 3) {
          // Add the 'category' column to the 'expenses' table in version 3
          await db.execute('''
          ALTER TABLE expenses ADD COLUMN category TEXT DEFAULT 'Uncategorized'
          ALTER TABLE month_savings 
          ADD COLUMN last_allocated_month TEXT UNIQUE, -- To track allocations by month
          ADD COLUMN remaining_savings REAL DEFAULT 0; -- To store leftover savings

        ''');
        }
      },
    );
  }

  // Retrieve start date
  Future<DateTime> getReportStartDate() async {
    final db = await database;
    final result = await db.query(
      'config',
      where: 'key = ?',
      whereArgs: ['reportStartDate'],
    );
    if (result.isNotEmpty) {
      return DateTime.parse(result.first['value'] as String);
    } else {
      // Default to the first day of the current month if no date is set
      final now = DateTime.now();
      return DateTime(now.year, now.month, 1);
    }
  }

  // Fetch all expenses
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    print(maps);
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  // Fetch expenses within a date range
  Future<List<Expense>> getExpensesInRange(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    final start = DateFormat('yyyy-MM-dd').format(startDate);
    final end = DateFormat('yyyy-MM-dd').format(endDate);

    final maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<void> addExpense(Expense expense) async {
    final db = await database;
    await db.insert('expenses', expense.toMap());
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth =
        DateTime(month.year, month.month + 1, 1).subtract(Duration(days: 1));
    final expenses = await db.rawQuery('''
    SELECT category, SUM(amount) as total
    FROM expenses
    WHERE date >= ? AND date <= ?
    GROUP BY category
  ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    return {
      for (var row in expenses)
        row['category'] as String: (row['total'] as num).toDouble()
    };
  }

  // Total spent today
  Future<double> getTotalSpentToday() async {
    final db = await database;
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final result = await db.rawQuery('''
      SELECT SUM(amount) AS totalSpent 
      FROM expenses 
      WHERE date(date) = ?
    ''', [todayStr]);

    return (result.first['totalSpent'] ?? 0.0) as double;
  }

  // Total spent this week
  Future<double> getTotalSpentThisWeek() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Monday as start
    final startStr = DateFormat('yyyy-MM-dd').format(startOfWeek);
    final endStr = DateFormat('yyyy-MM-dd').format(now);

    final result = await db.rawQuery('''
      SELECT SUM(amount) AS totalSpent 
      FROM expenses 
      WHERE date BETWEEN ? AND ?
    ''', [startStr, endStr]);

    return (result.first['totalSpent'] ?? 0.0) as double;
  }

  // Total spent this month
  Future<double> getTotalSpentThisMonth() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));
    final startStr = DateFormat('yyyy-MM-dd').format(startOfMonth);
    final endStr = DateFormat('yyyy-MM-dd').format(endOfMonth);

    final result = await db.rawQuery('''
      SELECT SUM(amount) AS totalSpent 
      FROM expenses 
      WHERE date BETWEEN ? AND ?
    ''', [startStr, endStr]);

    return (result.first['totalSpent'] ?? 0.0) as double;
  }

  // Top categories for the month
  Future<List<Map<String, dynamic>>> getTopCategoriesThisMonth() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));
    final startStr = DateFormat('yyyy-MM-dd').format(startOfMonth);
    final endStr = DateFormat('yyyy-MM-dd').format(endOfMonth);

    final result = await db.rawQuery('''
      SELECT category AS category, SUM(amount) AS total 
      FROM expenses 
      WHERE date BETWEEN ? AND ?
      GROUP BY category 
      ORDER BY total DESC
      LIMIT 5
    ''', [startStr, endStr]);

    return result
        .map((e) => {
              'category': e['category'] as String,
              'total': (e['total'] as num).toDouble(),
            })
        .toList();
  }

  // Pending or recurring expenses
  Future<List<Expense>> getPendingExpenses() async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [
        'Pending'
      ], // Assuming "Pending" is the category for such expenses
    );
    return result.map((e) => Expense.fromMap(e)).toList();
  }

// Combine data for Home Screen
  Future<Map<String, dynamic>> getHomeScreenData() async {
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    return {
      'totalSpentToday': await getTotalSpentToday(),
      'totalSpentThisWeek': await getTotalSpentThisWeek(),
      'totalSpentThisMonth': await getTotalSpentThisMonth(),
      'topCategories': await getTopCategoriesThisMonth(),
      'pendingExpenses': await getPendingExpenses(),
      'spendingLimit': await getSpendingLimit(currentMonth),
    };
  }

// Fetch all categories
  Future<List<String>> getCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((e) => e['name'] as String).toList();
  }

// Add a new category
  Future<void> addCategory(String categoryName) async {
    final db = await database;
    await db.insert(
      'categories',
      {'name': categoryName},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteCategory(String category) async {
    final db = await database; // Open the database connection
    await db.delete(
      'categories', // Table name
      where: 'name = ?', // Condition
      whereArgs: [category], // Arguments for the condition
    );
    print("Category '$category' deleted from the database.");
  }

  Future<void> updateCategory(String oldCategory, String newCategory) async {
    final db = await database;
    await db.update(
      'categories',
      {'name': newCategory},
      where: 'name = ?',
      whereArgs: [oldCategory],
    );
    print("Category '$oldCategory' updated to '$newCategory'.");
  }

  Future<void> deleteSpendingLimit({required String month, required String state}) async {
    final db = await database;
    String formattedMonth = DateFormat("yyyy-MM").format(DateTime.parse(month)); // Ensure proper format

    // Validate the state to ensure it is either 'default' or 'specific'
    if (state != 'default' && state != 'specific') {
      print('Invalid state. Must be either "default" or "specific".');
      return;
    }

    // Delete the record where both month and state match
    final result = await db.delete(
      'spending_limits',
      where: 'month = ? AND state = ?',
      whereArgs: [formattedMonth, state],
    );

    if (result > 0) {
      print('Spending limit for $formattedMonth with state $state deleted successfully.');
    } else {
      print('No spending limit found for $formattedMonth with state $state.');
    }
  }



  Future<void> addSpendingLimit({String? month, required double limitAmount, required bool isRecurring}) async {
    final db = await database;

    if (month == null) {
      // Insert default limit
      await db.insert(
        'spending_limits',
        {
          'month': null,  // Default limit does not need a month
          'limit_amount': limitAmount,
          'is_recurring': isRecurring ? 1 : 0,
          'state': 'default',
        },
      );
      print("Default limit saved successfully.");
    } else {
      // Insert monthly limit
      String formattedMonth = DateFormat("yyyy-MM").format(DateTime.parse(month)); // Ensure proper format
      await db.insert(
        'spending_limits',
        {
          'month': formattedMonth,
          'limit_amount': limitAmount,
          'is_recurring': isRecurring ? 1 : 0,
          'state': 'specific',
        },
      );
      print("Limit for $formattedMonth saved successfully.");
    }
  }




  Future<double?> getSpendingLimit(String? month) async {
    final db = await database;
    print("Fetching limit from database...");

    if (month == null) {
      // Fetch the default limit
      final result = await db.query(
        'spending_limits',
        where: 'state = ? AND month IS NULL',
        whereArgs: ['default'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final limit = result.first['limit_amount'];
        print("Default limit fetched: $limit");
        return limit is int ? limit.toDouble() : limit as double;
      } else {
        print("No default limit found.");
        return null;
      }
    } else {
      // Fetch the monthly limit
      String formattedMonth = DateFormat("yyyy-MM").format(DateTime.parse(month)); // Ensure proper format
      final result = await db.query(
        'spending_limits',
        where: 'state = ? AND month = ?',
        whereArgs: ['specific', formattedMonth],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final limit = result.first['limit_amount'];
        print("Limit for $formattedMonth fetched: $limit");
        return limit is int ? limit.toDouble() : limit as double;
      } else {
        print("No limit found for month: $month");
        return null;
      }
    }
  }



  Future<void> updateDefaultSpendingLimit(double newLimitAmount) async {
    final db = await database;

    // Check if a default limit exists
    final result = await db.query(
      'spending_limits',
      where: 'state = ? AND month IS NULL',
      whereArgs: ['default'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      // Update the existing default limit
      await db.update(
        'spending_limits',
        {'limit_amount': newLimitAmount},
        where: 'state = ? AND month IS NULL',
        whereArgs: ['default'],
      );
      print("Default limit updated successfully.");
    } else {
      // If no default limit exists, create one
      await db.insert(
        'spending_limits',
        {
          'month': null,  // Default limit does not need a month
          'limit_amount': newLimitAmount,
          'is_recurring': 1,
          'state': 'default',
        },
      );
      print("Default limit saved successfully.");
    }
  }



  Future<void> updateSpendingLimit(String month, double newLimitAmount) async {
    final db = await database;
    String formattedMonth = DateFormat("yyyy-MM").format(DateTime.parse(month)); // Ensure proper format

    // Check if the record exists
    final result = await db.query(
      'spending_limits',
      where: 'state = ? AND month = ?',
      whereArgs: ['specific', formattedMonth],
    );

    if (result.isNotEmpty) {
      // If it exists, update the limit
      await db.update(
        'spending_limits',
        {'limit_amount': newLimitAmount},
        where: 'state = ? AND month = ?',
        whereArgs: ['specific', formattedMonth],
      );
      print("Limit for $formattedMonth updated successfully.");
    } else {
      // If it doesn't exist, insert a new record
      await db.insert(
        'spending_limits',
        {
          'month': formattedMonth,
          'limit_amount': newLimitAmount,
          'state': 'specific',
          'is_recurring': 1, // Assuming recurring for the specific month
        },
      );
      print("Limit for $formattedMonth saved successfully.");
    }
  }






  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await database;
    return await db.query('savings_goals');
  }

  Future<void> addSavingsGoal(String description, double amount, DateTime endDate) async {
    final db = await database;
    await db.insert(
      'savings_goals',
      {
        'description': description,
        'goal_amount': amount,
        'amount_saved': 0.0,
        'date_created': DateTime.now().toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );
  }


  @pragma('vm:entry-point')
/*  Future<void> calculateAndUpdateSavings() async {
    final db = await database;
    final now = DateTime.now();
print('enter ohhhhhhhhhh');
    // Step 1: Fetch total expenses for the current month
    double totalExpenses = await getTotalSpentThisMonth();
    //double totalExpenses = 200000;
    // Step 2: Retrieve the spending limit for the current month
    final spendingLimit = await getSpendingLimit(DateFormat('yyyy-MM').format(now));
  //  final spendingLimit = 300000;

    // Step 3: Calculate savings for the current month
    double savings = spendingLimit! - totalExpenses;

    // Step 4: Update the savings table
    final monthYear =DateFormat("yyyy-MM").format(now);

    // Check if there's already an entry for the current month
    final existingSavings = await db.query(
      'month_savings',
      where: 'month_year = ?',
      whereArgs: [monthYear],
    );

    if (existingSavings.isNotEmpty) {
      // If an entry exists, update the existing record
      await db.update(
        'month_savings',
        {
          'total_expenses': totalExpenses,
          'spending_limit': spendingLimit,
          'savings': savings,
        },
        where: 'month_year = ?',
        whereArgs: [monthYear],
      );
      print("Savings updated for $monthYear.");
    } else {
      // If no entry exists, insert a new record
      await db.insert(
        'month_savings',
        {
          'month_year': monthYear,
          'total_expenses': totalExpenses,
          'spending_limit': spendingLimit,
          'savings': savings,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("New savings entry added for $monthYear.");
    }
  }*/

  Future<void> calculateAndUpdateSavings() async {
    final db = await database;
    final now = DateTime.now();
    final monthYear = DateFormat("yyyy-MM").format(now);

    print('Calculating savings for $monthYear.');

    // Step 1: Fetch total expenses for the current month
    double totalExpenses = await getTotalSpentThisMonth();

    // Step 2: Retrieve the spending limit for the current month
    final spendingLimit = await getSpendingLimit(monthYear);
    if (spendingLimit == null) {
      print("Error: No spending limit set for $monthYear.");
      return;
    }

    // Step 3: Calculate savings for the current month
    double calculatedSavings = spendingLimit - totalExpenses;
    print("Total expenses: $totalExpenses, Spending limit: $spendingLimit, Calculated savings: $calculatedSavings.");

    // Step 4: Check if there's already an entry for the current month
    final existingSavings = await db.query(
      'month_savings',
      where: 'month_year = ?',
      whereArgs: [monthYear],
    );

    if (existingSavings.isNotEmpty) {
      // If an entry exists, compare existing values to avoid redundant updates
      final currentRecord = existingSavings.first;
      double existingExpenses = currentRecord['total_expenses'] as double? ?? 0.0;
      double existingSavingsAmount = currentRecord['savings'] as double? ?? 0.0;

      if (existingExpenses == totalExpenses && existingSavingsAmount == calculatedSavings) {
        print("No changes detected for $monthYear. Skipping update.");
        return;
      }

      // Update only if there's a difference
      await db.update(
        'month_savings',
        {
          'total_expenses': totalExpenses,
          'spending_limit': spendingLimit,
          'savings': calculatedSavings,
        },
        where: 'month_year = ?',
        whereArgs: [monthYear],
      );
      print("Savings updated for $monthYear.");
    } else {
      // If no entry exists, insert a new record
      await db.insert(
        'month_savings',
        {
          'month_year': monthYear,
          'total_expenses': totalExpenses,
          'spending_limit': spendingLimit,
          'savings': calculatedSavings,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("New savings entry added for $monthYear.");
    }
  }


  /* @pragma('vm:entry-point')
  Future<void> allocateMonthlySavings() async {
    final db = await database;
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    print("Starting allocation for savings in $currentMonth");

    // Fetch total savings for the current month
    double totalSavings = await getTotalSavingsForMonth(currentMonth);
    print("Total savings for $currentMonth: $totalSavings");

    // Retrieve all goals with their target amounts and due dates in the future or today
    final goals = await db.query(
      'savings_goals',
      where: 'end_date >= ?',
      whereArgs: [now.toIso8601String()],
    );
    print("Goals eligible for allocation: $goals");

    // Calculate the total remaining amount needed for all goals
    double totalRemainingAmount = 0;
    for (var goal in goals) {
      double goal_amount = goal['goal_amount'] as double? ?? 0.0;
      double amount_saved = goal['amount_saved'] as double? ?? 0.0;
      totalRemainingAmount += goal_amount - amount_saved;
    }

    if (totalRemainingAmount <= 0) {
      print("No remaining amount required for any goals. Allocation skipped.");
      return;
    }

    // Allocate savings to each goal based on its remaining amount
    List<Map<String, dynamic>> allocations = [];
    double roundedTotalSavings = 0;

    for (var goal in goals) {
      double goal_amount = goal['goal_amount'] as double? ?? 0.0;
      double amount_saved = goal['amount_saved'] as double? ?? 0.0;

      if (goal_amount > amount_saved) {
        double goalRemainingAmount = goal_amount - amount_saved;
        double allocationPercentage = goalRemainingAmount / totalRemainingAmount;
        double goalSavings = totalSavings * allocationPercentage;

        // Round allocation and track remaining
        int roundedGoalSavings = goalSavings.round();
        roundedTotalSavings += roundedGoalSavings;

        allocations.add({
          'id': goal['id'],
          'description': goal['description'],
          'roundedSavings': roundedGoalSavings,
          'currentSaved': amount_saved,
        });
      }
    }

    // Distribute rounding difference
    int roundingDifference = totalSavings.round() - roundedTotalSavings.round();
    if (roundingDifference != 0) {
      distributeRoundingDifference(allocations, roundingDifference);
    }

    // Update the database with the final rounded savings
    for (var allocation in allocations) {
      double newAmountSaved = allocation['currentSaved'] + allocation['roundedSavings'];
      await db.update(
        'savings_goals',
        {
          'amount_saved': newAmountSaved,
        },
        where: 'id = ?',
        whereArgs: [allocation['id']],
      );
      print(
          "Updated goal ${allocation['description']}: new amount saved = $newAmountSaved for $currentMonth.");
    }
  }*/


  Future<void> allocateMonthlySavings() async {
    final db = await database;
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    print("Starting allocation for savings in $currentMonth");

    // Check if savings for the current month have already been allocated
    final allocationCheck = await db.query(
      'month_savings',
      where: 'last_allocated_month = ?',
      whereArgs: [currentMonth],
    );

    if (allocationCheck.isNotEmpty) {
      print("Savings for $currentMonth have already been allocated. Skipping allocation.");
      return;
    }

    // Fetch total savings for the current month
    double totalSavings = await getTotalSavingsForMonth(currentMonth);
    print("Total savings for $currentMonth: $totalSavings");

    // Retrieve all goals with their target amounts and due dates in the future or today
    final goals = await db.query(
      'savings_goals',
      where: 'end_date >= ?',
      whereArgs: [now.toIso8601String()],
    );
    print("Goals eligible for allocation: $goals");

    // Calculate the total remaining amount needed for all goals
    double totalRemainingAmount = 0;
    for (var goal in goals) {
      double goal_amount = goal['goal_amount'] as double? ?? 0.0;
      double amount_saved = goal['amount_saved'] as double? ?? 0.0;
      totalRemainingAmount += goal_amount - amount_saved;
    }

    if (totalRemainingAmount <= 0) {
      print("No remaining amount required for any goals. Allocation skipped.");
      return;
    }

    // Allocate savings to each goal based on its remaining amount
    List<Map<String, dynamic>> allocations = [];
    double roundedTotalSavings = 0;

    for (var goal in goals) {
      double goal_amount = goal['goal_amount'] as double? ?? 0.0;
      double amount_saved = goal['amount_saved'] as double? ?? 0.0;

      if (goal_amount > amount_saved) {
        double goalRemainingAmount = goal_amount - amount_saved;
        double allocationPercentage = goalRemainingAmount / totalRemainingAmount;
        double goalSavings = totalSavings * allocationPercentage;

        // Round allocation and track remaining
        int roundedGoalSavings = goalSavings.round();
        roundedTotalSavings += roundedGoalSavings;

        allocations.add({
          'id': goal['id'],
          'description': goal['description'],
          'roundedSavings': roundedGoalSavings,
          'currentSaved': amount_saved,
        });
      }
    }

    // Distribute rounding difference
    int roundingDifference = totalSavings.round() - roundedTotalSavings.round();
    if (roundingDifference != 0) {
      distributeRoundingDifference(allocations, roundingDifference);
    }

    // Update the database with the final rounded savings
    for (var allocation in allocations) {
      double newAmountSaved = allocation['currentSaved'] + allocation['roundedSavings'];
      await db.update(
        'savings_goals',
        {
          'amount_saved': newAmountSaved,
        },
        where: 'id = ?',
        whereArgs: [allocation['id']],
      );
      print(
          "Updated goal ${allocation['description']}: new amount saved = $newAmountSaved for $currentMonth.");
    }

    // Calculate and save leftover savings if total savings exceed the required amount
    double remainingSavings = totalSavings - roundedTotalSavings;
    if (remainingSavings > 0) {
      print("Remaining savings after allocation: $remainingSavings");
    }

    // Insert a record in the month_savings table to track allocation
    await db.insert(
      'month_savings',
      {
        'month_year': currentMonth,
        'total_expenses': await getTotalSpentThisMonth(),
        'spending_limit': await getSpendingLimit(currentMonth),
        'savings': totalSavings,
        'remaining_savings': remainingSavings,
        'last_allocated_month': currentMonth,
      },
    );

    print("Savings allocation completed for $currentMonth.");
  }



// Function to distribute rounding difference
  void distributeRoundingDifference(List<Map<String, dynamic>> allocations, int roundingDifference) {
    int index = 0;
    while (roundingDifference != 0) {
      if (roundingDifference > 0) {
        allocations[index]['roundedSavings'] += 1;
        roundingDifference -= 1;
      } else {
        allocations[index]['roundedSavings'] -= 1;
        roundingDifference += 1;
      }
      index = (index + 1) % allocations.length; // Cycle through allocations
    }
  }





  Future<double> getTotalSavingsForMonth(String month) async {
    final db = await database;
    print('formatted mot no oooooo non yes');
   // String formattedMonth = DateFormat("yyyy-MM").format(DateTime.parse(month));
    print('formatted mot no oooooo');
    print('formatted moth $month');
    // Query to calculate the total savings for the specified month
    final result = await db.rawQuery(
      'SELECT SUM(savings) AS total_savings FROM month_savings WHERE month_year = ?',
      [month],
    );

    // Check if the result is not empty and return the total savings
    if (result.isNotEmpty && result[0]['total_savings'] != null) {
      return result[0]['total_savings'] as double;
    } else {
      return 0.0; // Return 0 if no savings are found for the specified month
    }
  }



  Future<void> deleteGoalAndReallocate(int goalId) async {
    final db = await database;

    // Fetch the goal to be deleted
    final goalToDelete = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );

    if (goalToDelete.isEmpty) {
      print('Goal not found');
      return;
    }

    // Fetch all other goals
    final allGoals = await db.query('savings_goals');

    // Calculate total remaining amount (excluding the deleted goal)
    double totalRemainingAmount = 0;
    double amountToReallocate = 0;

    for (var goal in allGoals) {
      if (goal['id'] != goalId) {
        double goal_amount = goal['goal_amount'] as double? ?? 0.0;
        double amount_saved = goal['amount_saved'] as double? ?? 0.0;
        totalRemainingAmount += (goal_amount - amount_saved);
      } else {
        double goal_amount = goal['goal_amount'] as double? ?? 0.0;
        double amount_saved = goal['amount_saved'] as double? ?? 0.0;
        amountToReallocate = goal_amount - amount_saved; // Amount saved in the deleted goal
      }
    }

    if (totalRemainingAmount == 0) {
      print('No goals left to reallocate savings');
      return;
    }

    // Reallocate the savings from the deleted goal to other goals
    for (var goal in allGoals) {
      if (goal['id'] != goalId) {
        double goal_amount = goal['goal_amount'] as double? ?? 0.0;
        double amount_saved = goal['amount_saved'] as double? ?? 0.0;
        double goalRemainingAmount = goal_amount - amount_saved;

        double allocationPercentage = goalRemainingAmount / totalRemainingAmount;
        double goalSavings = amountToReallocate * allocationPercentage;

        // Update the goal's amount_saved in the database
        double newamount_saved = amount_saved + goalSavings;
        await db.update(
          'savings_goals',
          {
            'amount_saved': newamount_saved,
          },
          where: 'id = ?',
          whereArgs: [goal['id']],
        );
      }
    }

    // Finally, delete the goal from the database
    await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );

    print('Goal with ID $goalId deleted and savings reallocated.');
  }

  Future<Map<String, dynamic>> getNotificationData() async {
    final db = await database;

    // Fetch current month expenses
    final currentMonth = DateTime.now().toString().substring(0, 7); // Format: "YYYY-MM"
    final expensesData = await db.query(
      'month_savings',
      where: 'month_year = ?',
      whereArgs: [currentMonth],
    );

    double totalExpenses = expensesData.isNotEmpty
        ? expensesData[0]['total_expenses'] as double
        : 0.0;
    double spendingLimit = expensesData.isNotEmpty
        ? expensesData[0]['spending_limit'] as double
        : 0.0;
    double savings = expensesData.isNotEmpty
        ? expensesData[0]['savings'] as double
        : 0.0;

    // Fetch active goals
    final activeGoals = await db.query(
      'savings_goals',
      where: 'end_date >= ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );

    return {
      'totalExpenses': totalExpenses,
      'spendingLimit': spendingLimit,
      'savings': savings,
      'activeGoals': activeGoals,
    };
  }
}
