import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_device_list_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String institutionId;

  const CategorySelectionScreen({Key? key, required this.institutionId}) : super(key: key);

  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<Map<String, dynamic>> categories = [];
  final TextEditingController _categoryController = TextEditingController();
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // ✅ Fetch categories from backend (Global)
  Future<void> fetchCategories() async {
    try {
      setState(() => isLoading = true);

      final List<dynamic> data = await ApiService().getCategories();
      setState(() {
        categories = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load categories: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  // ✅ Add new category globally
  Future<void> addCategory() async {
    String newCategory = _categoryController.text.trim();
    if (newCategory.isEmpty || categories.any((cat) => cat['name'] == newCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid and unique category name!")),
      );
      return;
    }

    try {
      final Map<String, dynamic> response = await ApiService().addCategory(newCategory);

      if (response.containsKey('id')) {
        setState(() {
          categories.add({'id': response['id'].toString(), 'name': newCategory});
          _categoryController.clear();
        });
      } else {
        throw Exception("Invalid API response format");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add category: ${e.toString()}")),
      );
    }
  }

  // ✅ Remove category globally
  Future<void> removeCategory(String categoryId) async {
    try {
      await ApiService().deleteCategory(categoryId);

      setState(() {
        categories.removeWhere((category) => category['id'].toString() == categoryId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category removed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove category: ${e.toString()}")),
      );
    }
  }


  void showRemoveCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Category to Remove"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((category) {
                return ListTile(
                  title: Text(category['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      removeCategory(category['id'].toString());
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ✅ Navigate to Device List Screen
  void navigateToDevices(String categoryId, String categoryName) {
    Navigator.pushNamed(
      context,
      '/device_list',
      arguments: {
        'institutionId': widget.institutionId,
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text("Device Categories", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Manage Device Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Enter Category Name",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: addCategory,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF075056)),
                  child: const Text("Add Category", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: showRemoveCategoryDialog,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5B04)),
                  child: const Text("Remove Category", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(categories[index]['name']),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => navigateToDevices(
                          categories[index]['id'].toString(), categories[index]['name']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
