import 'package:flutter/material.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/screen/widget/custom_dialog.dart';

class SpendingLimitsConfigScreen extends StatefulWidget {
  @override
  _SpendingLimitsConfigScreenState createState() => _SpendingLimitsConfigScreenState();
}

class _SpendingLimitsConfigScreenState extends State<SpendingLimitsConfigScreen> {
  double defaultSpendingLimit = 0.0;
  Map<String, double> monthlyLimits = {}; // Key: Month-Year, Value: Spending Limit

  @override
  void initState() {
    super.initState();
    fetchLimits();
  }

  Future<void> fetchLimits() async {
    final defaultLimit = await DatabaseService.instance.getSpendingLimit(null);
    setState(() {
      defaultSpendingLimit = defaultLimit ?? 0.0;
    });
    //DateTime monthDate = DateTime(now.year, now.month + i, 1);
   // String formattedMonth = DateFormat('yyyy-MM-dd').format(monthDate);


    final now = DateTime.now();
    Map<String, double> fetchedMonthlyLimits = {};
    for (int i = 0; i < 12; i++) {
      DateTime monthDate = DateTime(now.year, now.month + i, 1);
      String formattedMonth = DateFormat('yyyy-MM-dd').format(monthDate);

      final monthlyLimit = await DatabaseService.instance.getSpendingLimit(formattedMonth);
      if (monthlyLimit != null) {
        fetchedMonthlyLimits[formattedMonth] = monthlyLimit;
      }
    }

    setState(() {
      monthlyLimits = fetchedMonthlyLimits;
    });
  }

  Future<void> saveDefaultLimit(double value) async {
    await DatabaseService.instance.updateDefaultSpendingLimit(value);
    setState(() {
      defaultSpendingLimit = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Default spending limit saved successfully!")),
    );
  }

  Future<void> saveMonthlyLimit(String month, double value) async {
    await DatabaseService.instance.updateSpendingLimit( month,  value);
    setState(() {
      monthlyLimits[month] = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Monthly limit for $month saved successfully!")),
    );
  }

  Future<void> resetMonthlyLimit(String month) async {
    await DatabaseService.instance.deleteSpendingLimit(month: month, state: 'specific');
    setState(() {
      monthlyLimits.remove(month);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Monthly limit for $month reset successfully!")),
    );
  }

  String formatMonth(DateTime date) => DateFormat.yMMMM().format(date);

  @override
  Widget build(BuildContext context) {
    TextEditingController defaultController =
    TextEditingController(text: defaultSpendingLimit > 0 ? defaultSpendingLimit.toStringAsFixed(2) : "");

    return Scaffold(
      appBar: AppBar(
        title: Text("Spending Limits Configuration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Default Spending Limit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: defaultController,
                    keyboardType: TextInputType.number,
                    //decoration: InputDecoration(hintText: "Edit default spending limit"),
                    decoration: InputDecoration(hintText: "0.0"),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    color: Colors.red,
                      Icons.edit),
                  onPressed: () {
                    showCustomDialog(
                      context: context,
                      title: 'Enter default spending limit', // Example title
                      onSave: (double value) {
                        // Handle the value saved by the user
                     //   double value = value;
                        saveDefaultLimit(value);
                        print("Saved value: $value");
                        // You can use this value to update your database, state, or perform any other action
                      },
                      onCancel: () {
                        // Handle the cancel action
                        print("Cancel action triggered");
                        // Any cleanup or resetting actions can be placed here
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // If default limit is not set, show the tip card
            if (defaultSpendingLimit == 0)
              Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Click on the edit icon on the left to Set a default spending limit to help manage your monthly expenses. "
                        "You can also customize limits for specific months once the default is set.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            // Monthly Spending Limit Overrides Section
            if (defaultSpendingLimit > 0)
              ...[
                Text(
                  "Monthly Overrides",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      DateTime now = DateTime.now();
                      DateTime month = DateTime(now.year, now.month + index, 1);
                      String formattedMonth =  DateFormat('yyyy-MM-dd').format(month);

                      return Card(
                        child: ListTile(
                          title: Text(formattedMonth),
                          subtitle: Text(
                            monthlyLimits[formattedMonth] != null
                                ? "Limit: \$${monthlyLimits[formattedMonth]!.toStringAsFixed(2)}"
                                : "Default: \$${defaultSpendingLimit.toStringAsFixed(2)}",
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => SpendingLimitEditor(
                                  month: formattedMonth,
                                  currentLimit:
                                  monthlyLimits[formattedMonth] ?? defaultSpendingLimit,
                                  onSave: (value) => saveMonthlyLimit(formattedMonth, value),
                                  onReset: () => resetMonthlyLimit(formattedMonth),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class SpendingLimitEditor extends StatelessWidget {
  final String month;
  final double currentLimit;
  final Function(double) onSave;
  final Function onReset;

  const SpendingLimitEditor({
    required this.month,
    required this.currentLimit,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: currentLimit.toStringAsFixed(2));

    return AlertDialog(
      title: Text("Edit Spending Limit for $month"),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: "Enter new limit"),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.save_outlined),
          onPressed: () {
            double value = double.tryParse(controller.text) ?? currentLimit;
            onSave(value);
            Navigator.pop(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.restore_page),
          onPressed: () {
            onReset();
            Navigator.pop(context);
          },

        ),
      ],
    );
  }
}
