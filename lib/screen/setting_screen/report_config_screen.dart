import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  final Function(int) navigateToTab;

  SettingsScreen({required this.navigateToTab, Key? key}) : super(key: key);

  final List<Map<String, dynamic>> settingsOptions = [

    {"icon": Icons.language, "title": "Language Selection", "route": "/languageSelection"},
    {"icon": Icons.upload, "title": "Export Data", "route": "/exportData"},
    {"icon": Icons.download, "title": "Import Data", "route": "/importData"},
    {"icon": Icons.savings, "title": "Saving Goal", "route": "/savingGoal"},
    {"icon": Icons.repeat, "title": "Recurring Expenses", "route": "/recurringExpenses"},
    {"icon": Icons.lock, "title": "Add PIN", "route": "/addPin"},
    {"icon": Icons.fingerprint, "title": "Biometric Auth", "route": "/biometricAuth"},
    {"icon": Icons.backup, "title": "Backup & Restore", "route": "/backupRestore"},
    {"icon": Icons.privacy_tip, "title": "Privacy & Security", "route": "/privacySecurity"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
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
              Get.toNamed(settingsOptions[index]['route'], arguments: navigateToTab);
            },
          );
        },
      ),
    );
  }
}
