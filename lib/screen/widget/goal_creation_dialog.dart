import 'package:flutter/material.dart';

class GoalCreationDialog extends StatefulWidget {
  final Function(String, double, bool, DateTime?) onSave;

  const GoalCreationDialog({required this.onSave, Key? key}) : super(key: key);

  @override
  State<GoalCreationDialog> createState() => _GoalCreationDialogState();
}

class _GoalCreationDialogState extends State<GoalCreationDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _deductFromBudget = false;
  DateTime? _selectedEndDate;

  void _pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Savings Goal"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Goal Description"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Goal Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Deduct from Budget"),
                Switch(
                  value: _deductFromBudget,
                  onChanged: (value) {
                    setState(() {
                      _deductFromBudget = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("End Date"),
                TextButton(
                  onPressed: _pickEndDate,
                  child: Text(
                    _selectedEndDate == null
                        ? "Select Date"
                        : "${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final description = _descriptionController.text;
            final amount = double.tryParse(_amountController.text) ?? 0.0;
            widget.onSave(description, amount, _deductFromBudget, _selectedEndDate);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
