import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:my_expense/database/database_service.dart';


class HelperFunction{
  void scheduleMonthlyTask() async {
    // Get the current date and calculate the last day of the month
    DateTime now = DateTime.now();
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    DateTime lastHourOfMonth = nextMonth.subtract(const Duration(hours: 1));

    // Schedule the alarm
    await AndroidAlarmManager.oneShotAt(
      lastHourOfMonth, // Run at the last hour of the month
      0,               // Alarm ID (unique identifier)
      monthlyTask,     // Function to call
      exact: true,
      wakeup: true,
    );

    print("Task scheduled for $lastHourOfMonth.");
  }

  Future<void> monthlyTask() async {
    print("Running scheduled monthly task...");
    await DatabaseService.instance.calculateAndUpdateSavings();
    await DatabaseService.instance.allocateMonthlySavings();
    print("Monthly task completed.");
  }


}