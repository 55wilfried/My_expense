/*
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:my_expense/model/expens_modle.dart';
class Dbsecond{
  static final Dbsecond instance = Dbsecond._privateConstructor();
  static Database? _database;
  Dbsecond._privateConstructor();



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
        ''');
        }
      },
    );
  }


  // Save start date
  Future<void> setReportStartDate(DateTime startDate) async {
    final db = await database;
    await db.insert(
      'config',
      {'key': 'reportStartDate', 'value': startDate.toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getMonthlyReport() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    final startDateStr = DateFormat('yyyy-MM-dd').format(startOfMonth);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endOfMonth);

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS expenseCount,
             SUM(amount) AS totalSpent
      FROM expenses
      WHERE date BETWEEN ? AND ?
    ''', [startDateStr, endDateStr]);

    final report = result.first;
    return {
      'expenseCount': report['expenseCount'] ?? 0,
      'totalSpent': report['totalSpent'] ?? 0.0,
    };
  }
  Future<List<double>> getExpensesByWeek() async {
    final now = DateTime.now();
    final db = await database;
    final startOfWeek = now.subtract(Duration(days: 6)); // 7 days including today
    final expenses = await db.rawQuery('''
    SELECT date, SUM(amount) as total
    FROM expenses
    WHERE date >= ? AND date <= ?
    GROUP BY date
  ''', [startOfWeek.toIso8601String(), now.toIso8601String()]);

    // Map the expenses to daily totals (default to 0 for missing days)
    final dailyExpenses = List.generate(7, (index) => 0.0); // 7 days
    for (var row in expenses) {
      final date = DateTime.parse(row['date'] as String); // Cast to String
      final dayIndex = date.difference(startOfWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyExpenses[dayIndex] = (row['total'] as num).toDouble(); // Cast to num and then double
      }
    }

    return dailyExpenses;
  }
  Future<List<Map<String, dynamic>>> fetchExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }
}*/
