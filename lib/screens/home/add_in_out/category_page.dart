import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController categoryController = TextEditingController();

  Future<void> addCategory() async {
    if (categoryController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': categoryController.text,
      });
      categoryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Nama Kategori'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addCategory,
              child: Text('Simpan Kategori'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index]['name'];
                      return ListTile(
                        title: Text(category),
                        onTap: () {
                          Navigator.pop(context, category);
                        },
                      );
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
