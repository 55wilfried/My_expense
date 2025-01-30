import 'package:flutter/material.dart';
import 'package:my_expense/database/database_service.dart';

import '../../utils/colors_utils.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  List<String> _categories = [];

  // Predefined list of colors for borders and text
  final List<Color> _colors = [
    Colors.teal,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await _dbService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _showAddOrEditCategoryDialog({String? existingCategory, int? index}) {
    final TextEditingController _categoryController = TextEditingController(
      text: existingCategory,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingCategory == null ? "Add Category" : "Edit Category"),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: "Category Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final categoryName = _categoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  if (existingCategory == null) {
                    // Add new category
                    await _dbService.addCategory(categoryName);
                  } else {
                    // Update existing category
                    await _dbService.updateCategory(existingCategory, categoryName);
                  }
                  _fetchCategories();
                  Navigator.of(context).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existingCategory == null
                            ? "Category '$categoryName' added successfully!"
                            : "Category updated to '$categoryName'!",
                      ),
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
              child: Text(existingCategory == null ? "Save" : "Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCategory(String category) async {
    await _dbService.deleteCategory(category);
    _fetchCategories();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Category '$category' deleted successfully!"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = (screenWidth / 2) - 16; // Divide by 2 and subtract padding
    final cardHeight = screenHeight / 6; // Adjust height dynamically based on screen size6

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Categories"),
        centerTitle: true,
        backgroundColor: ColorsUtils.quinaryTeal,
      ),
      body: _categories.isEmpty
          ? Center(
        child: Text(
          "No categories available.\nTap '+' to add a new one!",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            final borderColor = _colors[index % _colors.length];
            final textColor = _colors[(index + 1) % _colors.length];
            final category = _categories[index];

            return SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: borderColor, width: 2.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: textColor,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                         /* IconButton(
                            onPressed: () {
                              _showAddOrEditCategoryDialog(
                                existingCategory: category,
                                index: index,
                              );
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "Edit Category",
                          ),*/
                          IconButton(
                            onPressed: () {
                              _deleteCategory(category);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Delete Category",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditCategoryDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: "Add Category",
      ),
    );
  }
}
