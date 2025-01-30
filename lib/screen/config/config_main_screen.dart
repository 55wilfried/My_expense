import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfigMainScreen extends StatelessWidget {
  final Function(int) navigateToTab;

  ConfigMainScreen({required this.navigateToTab, Key? key}) : super(key: key);

  final List<Map<String, dynamic>> settingsOptions = [
    {
      "icon": Icons.monetization_on,
      "title": "Spending Limits",
      "route": "/spendingLimits"
    },
    {
      "icon": Icons.category,
      "title": "Expenses Categories",
      "route": "/CategoriesScreen"
    },

    {
      "icon": Icons.repeat,
      "title": "Recurring Expenses",
      "route": "/recurringExpenses"
    },

    {
      "icon": Icons.notifications,
      "title": "Notifications",
      "route": "/notifications"
    },


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration"),
      ),
      body: ListView.builder(
        itemCount: settingsOptions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(settingsOptions[index]['icon']),
            title: Text(settingsOptions[index]['title']),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
// Navigate to the selected settings screen
              Get.toNamed(settingsOptions[index]['route'],
                  arguments: navigateToTab);
            },
          );
        },
      ),
    );
  }
}
