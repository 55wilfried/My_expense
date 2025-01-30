import 'package:flutter/material.dart';
import 'package:my_expense/screen/expensive_screen/epensive_screen.dart';
import 'package:my_expense/screen/expensive_screen/expensive_list_screen.dart';
import 'package:my_expense/screen/expensive_screen/save_old_expensive.dart';

class ExpensiveHomeScreen extends StatefulWidget {
  @override
  _ExpensiveHomeScreenState createState() => _ExpensiveHomeScreenState();
}

class _ExpensiveHomeScreenState extends State<ExpensiveHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Function to navigate to a specific tab
  void navigateToTab(int index) {
    if (index < _tabController.length) {
      setState(() {
        _tabController.animateTo(index); // Smoothly animate to the tab
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Enables scrolling for the tabs
          tabs: const [
            Tab(
              icon: Icon(Icons.add), // Icon for "Add Expensive"
              text: "Add Expensive",
            ),
            Tab(
              icon: Icon(Icons.list), // Icon for "Expenses List"
              text: "Expenses List",
            ),
            Tab(
              icon: Icon(Icons.save_alt), // Icon for "Save Old Expensive"
              text: "Save Old Expensive",
            ),
          ],

        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ExpenseEntryScreen(), // Tab 1
          ExpenseListScreen(), // Tab 2
          SaveOldExpenseScreen(), // Tab 3 (placeholder for now)
        ],
      ),
    );
  }
}
