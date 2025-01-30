import 'package:flutter/material.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SavingsGoalsScreen extends StatefulWidget {
  @override
  _SavingsGoalsScreenState createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  List<Map<String, dynamic>> goals = [];

  @override
  void initState() {
    super.initState();
    getGoal();
  }

  Future<void> getGoal() async {
    goals = await DatabaseService.instance.getAllGoals();
    setState(() {});
  }

  Future<void> _addNewGoal(String description, double goal_amount, DateTime endDate) async {
    await DatabaseService.instance.addSavingsGoal(description, goal_amount, endDate);
    setState(() {
      // Add the new goal to the list of goals
      goals = List.from(goals); // Convert to mutable if necessary
      goals.add({
        "id": goals.length + 1,
        "description": description,
        "goal_amount": goal_amount,
        "amount_saved": 0.0,
        "endDate": endDate.toIso8601String(),
      });
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Goal added successfully!")));
  }

  void _deleteGoal(int goalId) async {
    try {
      await DatabaseService.instance.deleteGoalAndReallocate(goalId);
      setState(() {
        goals.removeWhere((goal) => goal['id'] == goalId);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Goal deleted successfully!")));
    } catch (e) {
      print('Error deleting goal: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting goal!")));
    }
  }

  void _showAddGoalDialog() {
    final _descriptionController = TextEditingController();
    final _amountController = TextEditingController();
    DateTime? _selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Add New Goal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Goal Description"),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: "Goal Amount"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                },
                child: Text(_selectedDate == null
                    ? "Select End Date"
                    : "End Date: ${_selectedDate!.toLocal()}".split(' ')[0]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_descriptionController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty &&
                    _selectedDate != null) {
                  _addNewGoal(
                    _descriptionController.text,
                    double.parse(_amountController.text),
                    _selectedDate!,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalSaved = goals.fold(0.0, (sum, goal) => sum + (goal['amount_saved'] ?? 0.0));
    double totalGoal = goals.fold(0.0, (sum, goal) => sum + (goal['goal_amount'] ?? 0.0));
    double progressPercentage = (totalSaved / (totalGoal == 0 ? 1 : totalGoal)) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text("Savings Goals"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Savings Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Total Saved: \$${totalSaved.toStringAsFixed(2)}"),
                    Text("Total Goals: \$${totalGoal.toStringAsFixed(2)}"),
                    Text("Progress: ${progressPercentage.toStringAsFixed(1)}%"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            // Graph Card (Using Syncfusion Chart)
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Savings Progress'),
                    legend: Legend(isVisible: false),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      ColumnSeries<Map<String, dynamic>, String>(
                        dataSource: goals,
                        xValueMapper: (goal, _) => goal['description'], // X-axis: Goal description
                        yValueMapper: (goal, _) {
                          double amount_saved = goal['amount_saved'] ?? 0.0; // Ensure it's not null
                          double goal_amount = goal['goal_amount'] ?? 1.0; // Avoid division by zero
                          return (amount_saved / goal_amount * 100).clamp(0.0, 100.0); // Y-axis: Percentage progress
                        },
                        dataLabelSettings: DataLabelSettings(isVisible: true), // Show data labels
                        name: "Progress",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Goals List
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progress = (goal['goal_amount'] != null && goal['amount_saved'] != null && goal['goal_amount'] > 0)
                      ? (goal['amount_saved'] / goal['goal_amount']).clamp(0.0, 1.0)
                      : 0.0; // Return 0.0 if either value is null or goal_amount is 0

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(goal['description'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteGoal(goal['id']);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text("Saved: \$${goal['amount_saved'] ?? 0.0} / \$${goal['goal_amount'] ?? 0.0}"),
                          Text("Progress: ${(progress * 100).toStringAsFixed(1)}%"),
                          LinearProgressIndicator(value: progress),  // Ensure progress is passed correctly here
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
