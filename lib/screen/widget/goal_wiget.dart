import 'package:flutter/material.dart';

class GoalProgressWidget extends StatelessWidget {
  final String description;
  final double goal_amount;
  final double amount_saved;

  const GoalProgressWidget({
    required this.description,
    required this.goal_amount,
    required this.amount_saved,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (amount_saved / goal_amount).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 10),
            Text("Saved: \$${amount_saved.toStringAsFixed(2)} / \$${goal_amount.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
