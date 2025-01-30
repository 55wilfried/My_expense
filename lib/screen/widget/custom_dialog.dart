import 'package:flutter/material.dart';

void showCustomDialog({
  required BuildContext context,
  required String title, // Title of the dialog
  required Function(double) onSave, // Callback function for save action
  required Function() onCancel, // Callback function for cancel action
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: CustomCardWidget(
          title: title,
          onSave: onSave,
          onCancel: onCancel,
        ),
      );
    },
  );
}

class CustomCardWidget extends StatefulWidget {
  final String title;
  final Function(double) onSave;
  final Function onCancel;

  CustomCardWidget({
    required this.title,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _CustomCardWidgetState createState() => _CustomCardWidgetState();
}

class _CustomCardWidgetState extends State<CustomCardWidget> {
  final _controller = TextEditingController();

  void _saveValue() {
    String enteredValue = _controller.text;
    if (enteredValue.isNotEmpty) {
      double value = double.tryParse(enteredValue) ?? 0.0; // Convert entered value to integer
      widget.onSave(value); // Return the entered value via onSave callback
      Navigator.pop(context); // Close the dialog
    } else {
      print("Please enter a valid value.");
    }
  }

  void _cancelAction() {
    widget.onCancel(); // Call the passed cancel callback
    Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Spending Limit amount',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.save, color: Colors.green),
                  onPressed: _saveValue, // Save the value entered by the user
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: _cancelAction, // Cancel the action
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
