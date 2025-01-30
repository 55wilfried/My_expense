import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:my_expense/model/saving_goal.dart';
import 'package:my_expense/screen/expensive_screen/epensive_screen.dart';
import 'package:my_expense/screen/expensive_screen/expensive_home_screen.dart';
import 'package:my_expense/screen/expensive_screen/expensive_list_screen.dart';
import 'package:my_expense/screen/home_screen/add_goal_screen.dart';
import 'package:my_expense/screen/home_screen/home_screen.dart';
import 'package:my_expense/screen/report_screen/report_screen.dart';
import 'package:my_expense/screen/setting_screen/report_config_screen.dart';

class BaseScreen extends StatefulWidget {
  final int selectedIndex;
  const BaseScreen({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      ExpensiveHomeScreen(),
     /* AddSavingsGoalScreen(
        onSave: (SavingsGoal goal) {
          // Handle goal save
        },
      ),*/
      ReportScreen(),
      SettingsScreen(navigateToTab: (int ) {  },),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures title is always visible
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.file),
            label: 'Expenses'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartPie),
            label: 'Report'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gear),
            label: 'Setting'.tr,
          ),
        ],
      ),

    );
  }
}
