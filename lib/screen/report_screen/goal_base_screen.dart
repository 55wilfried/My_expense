import 'package:flutter/material.dart';
import 'package:my_expense/screen/expensive_screen/epensive_screen.dart';
import 'package:my_expense/screen/expensive_screen/expensive_list_screen.dart';
import 'package:my_expense/screen/expensive_screen/save_old_expensive.dart';
import 'package:my_expense/screen/home_screen/add_goal_screen.dart';

class GoalHomeScreen extends StatefulWidget {
  @override
  _GoalHomeScreenState createState() => _GoalHomeScreenState();
}

class _GoalHomeScreenState extends State<GoalHomeScreen> with SingleTickerProviderStateMixin {
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
            Tab(text: "Add Goal"),
            Tab(text: "Goal Report"),
            Tab(text: "Save Old Expensive"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SavingsGoalsScreen(), // Tab 1
          ExpenseListScreen(), // Tab 2
          SaveOldExpenseScreen(), // Tab 3 (placeholder for now)
        ],
      ),
    );
  }
}
