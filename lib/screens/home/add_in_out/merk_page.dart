import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MerkPage extends StatefulWidget {
  @override
  _MerkPageState createState() => _MerkPageState();
}

class _MerkPageState extends State<MerkPage> {
  final TextEditingController merkController = TextEditingController();

  Future<void> addMerk() async {
    if (merkController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('merks').add({
        'name': merkController.text,
      });
      merkController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Merk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: merkController,
              decoration: InputDecoration(labelText: 'Nama Merk'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addMerk,
              child: Text('Simpan Merk'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('merks').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final merks = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: merks.length,
                    itemBuilder: (context, index) {
                      final merk = merks[index]['name'];
                      return ListTile(
                        title: Text(merk),
                        onTap: () {
                          Navigator.pop(context, merk);
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
