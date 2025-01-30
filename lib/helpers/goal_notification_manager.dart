import 'dart:async';

import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/screen/widget/notification.dart';

class GoalNotificationManager {
  final NotificationService notificationService;

  GoalNotificationManager(this.notificationService);

  Future<void> generateNotifications() async {
    final data = await DatabaseService.instance.getNotificationData();

    final totalExpenses = data['totalExpenses'] as double;
    final spendingLimit = data['spendingLimit'] as double;
    final savings = data['savings'] as double;
    final activeGoals = data['activeGoals'] as List<Map<String, dynamic>>;

    // Notify about spending
    if (totalExpenses > spendingLimit) {
      await notificationService.showNotification(
        title: 'Alert: Spending Limit Exceeded!',
        body:
        'You have spent \$${totalExpenses.toStringAsFixed(2)}, which exceeds your limit of \$${spendingLimit.toStringAsFixed(2)}. Try to reduce expenses to save more.',
      );
    } else {
      await notificationService.showNotification(
        title: 'Great Job!',
        body:
        'You are within your spending limit this month. Keep it up and save more!',
      );
    }

    // Notify about active goals
    for (var goal in activeGoals) {
      final description = goal['description'] as String;
      final goalAmount = goal['goal_amount'] as double;
      final amountSaved = goal['amount_saved'] as double;

      if (amountSaved < goalAmount) {
        final remaining = goalAmount - amountSaved;
        await notificationService.showNotification(
          title: 'Goal Reminder: $description',
          body:
          'You have \$${remaining.toStringAsFixed(2)} left to save for your goal "$description". Keep going!',
        );
      }
    }
  }
}
