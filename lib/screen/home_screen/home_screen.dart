import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_expense/screen/config/config_main_screen.dart';
import 'package:my_expense/screen/expensive_screen/epensive_screen.dart';
import 'package:my_expense/screen/config/expense_categorir.dart';
import 'package:my_expense/screen/home_screen/add_goal_screen.dart';
import 'package:my_expense/screen/home_screen/quick_stats_screen.dart';
import 'package:my_expense/screen/setting_screen/report_config_screen.dart';
import 'package:my_expense/screen/week_report_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0; // To track the current tab index

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: _currentIndex);

    // Listen to tab changes to update the current index
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
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
        _currentIndex = index; // Update the current index
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
          tabs: const [
            Tab(
              icon: Icon(Icons.bar_chart), // Icon for Quick Stats
              text: "Quick Stats",
            ),
            Tab(
              icon: Icon(Icons.flag), // Icon for Goal
              text: "Goal",
            ),
            Tab(
              icon: Icon(Icons.settings), // Icon for Configuration
              text: "Configuration",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          QuickStatsScreen(), // Tab 1
          SavingsGoalsScreen(), // Tab 2
          //SettingsScreen(navigateToTab: navigateToTab), // Pass the function to SettingsScreen
          ConfigMainScreen(navigateToTab: navigateToTab),
        ],
      ),
    );
  }
}
