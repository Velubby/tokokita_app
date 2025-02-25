import 'package:flutter/material.dart';
import '/models/category_model.dart';
import '/services/firestore_service.dart';

class CategoryPage extends StatefulWidget {
  final String teamId; // Pass teamId as argument to use in this page

  const CategoryPage({super.key, required this.teamId});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Fetch categories based on the current teamId
  Future<void> _loadCategories() async {
    List<Category> fetchedCategories =
        await _firestoreService.getCategoriesByTeamId(widget.teamId);
    setState(() {
      categories = fetchedCategories;
    });
  }

  // Add a new category to Firestore
  void addCategory() async {
    if (categoryController.text.isNotEmpty) {
      Category newCategory = Category(
        categoryId:
            DateTime.now().toString(), // or use Firestore auto-generated ID
        teamId: widget.teamId,
        name: categoryController.text.trim(),
      );

      // Add the new category to Firestore
      await _firestoreService.addCategory(newCategory);

      // Refresh the list of categories
      _loadCategories();

      // Clear the input field
      categoryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih atau Tambah Kategori'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Tambah Kategori Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addCategory,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(categories[index].name),
                          onTap: () {
                            Navigator.pop(context, categories[index].name);
                          },
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
