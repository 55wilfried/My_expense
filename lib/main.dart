import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/helpers/helper_function.dart';
import 'package:my_expense/screen/config/expense_categorir.dart';
import 'package:my_expense/screen/config/spending_limits.dart';
import 'package:my_expense/screen/splash_screen.dart';
import 'package:my_expense/screen/widget/notification.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helpers/goal_notification_manager.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize(); // Register the task to run at the end of the month
  runApp(const MyApp());
  final notificationService = NotificationService();
  final goalNotificationManager =
  GoalNotificationManager(notificationService);
  await notificationService.initialize();

  // Generate notifications every 24 hours
  Timer.periodic(const Duration(hours: 24), (timer) async {
    await goalNotificationManager.generateNotifications();
  });
  HelperFunction().scheduleMonthlyTask();
  scheduleTestTask();
}

Future<void> testTask() async {
  print("Test task executed at ${DateTime.now()}");
}

void scheduleTestTask() async {
  // Initial test: one-shot alarm after 3 seconds
  await AndroidAlarmManager.oneShot(
    const Duration(seconds: 03), // Delay of 3 seconds
    1,                          // Unique ID for this alarm
    PerformUpdate,                   // Function to execute
    exact: true,
    wakeup: true,
  );
  print("One-shot test task scheduled in 3 seconds.");

  // Periodic task: every 15 seconds

}

Future<void> PerformUpdate() async {
  try {
    print("PerformUpdate called at ${DateTime.now()}");
    print("Monthly task executed successfully. ohhhhh");
    await DatabaseService.instance.calculateAndUpdateSavings();

    await DatabaseService.instance.allocateMonthlySavings();
    print("Monthly task executed successfully.");
  } catch (e) {
    print("Error executing monthly task: $e");
  }
}

Future<void> _requestAlarmPermission() async {
  // Request SCHEDULE_EXACT_ALARM permission for Android 12+
  if (await Permission.scheduleExactAlarm.isDenied) {
    // Request permission
    await Permission.scheduleExactAlarm.request();
  }
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
 initState()  {
    super.initState();
    _requestAlarmPermission();
    //scheduleMonthlyTask();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      // locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      //  translations: Languages(),
      home:  SplashScreen(),
      getPages: [
        GetPage(name: '/spendingLimits', page: () => SpendingLimitsConfigScreen()),
        GetPage(name: '/CategoriesScreen', page: () => CategoriesScreen()),

        // Add other routes here as needed
      ],
    );
  }
}
