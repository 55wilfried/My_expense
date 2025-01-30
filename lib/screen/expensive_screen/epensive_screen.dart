import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/model/expens_modle.dart';
import 'package:my_expense/utils/colors_utils.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final VoidCallback? onGoToCategories;

  ExpenseEntryScreen({super.key, this.onGoToCategories});

  @override
  _ExpenseEntryScreenState createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String? selectedCategory;
  List<String> categories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final fetchedCategories = await DatabaseService.instance.getCategories();
    setState(() {
      categories = fetchedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        centerTitle: true,
        backgroundColor: ColorsUtils.quinaryTeal,
      ),
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF84fab0), Color(0xFF8fd3f4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: Center(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Record Your Expense",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        items: categories
                            .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        decoration: _inputDecoration(
                          labelText: "Select Category",
                          icon: Icons.category,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      // Description TextField
                      TextFormField(
                        controller: descriptionController,
                        decoration: _inputDecoration(
                          labelText: "Description",
                          icon: Icons.description,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      // Amount TextField
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          labelText: "Amount",
                          icon: Icons.attach_money,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      // Save Button
                      isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        ),
                      )
                          : ElevatedButton.icon(
                        onPressed: _saveExpense,
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                          Size(screenSize.width, screenSize.height * 0.07),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "Save Expense",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (selectedCategory == null) {
      Get.snackbar("No Category Selected", "Please select a category.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    final description = descriptionController.text.trim();
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (description.isEmpty || amount == null || amount <= 0) {
      Get.snackbar(
        "Invalid Input",
        "Please enter valid details.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final expense = Expense(
        description: description,
        amount: amount,
        category: selectedCategory!,
        date: DateTime.now(),
      );
      await DatabaseService.instance.addExpense(expense);

      setState(() {
        descriptionController.clear();
        amountController.clear();
        selectedCategory = null;
        isLoading = false;
      });

      Get.snackbar("Success", "Expense added successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("Error", "Failed to save expense.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
