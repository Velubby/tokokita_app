import 'package:flutter/material.dart';
import '/models/brand_model.dart';
import '/services/firestore_service.dart';

class BrandPage extends StatefulWidget {
  final String teamId; // Pass teamId as argument to use in this page

  const BrandPage({super.key, required this.teamId});

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final TextEditingController brandController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  List<Brand> brands = [];

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  // Fetch brands based on the current teamId
  Future<void> _loadBrands() async {
    List<Brand> fetchedBrands =
        await _firestoreService.getBrandsByTeamId(widget.teamId);
    setState(() {
      brands = fetchedBrands;
    });
  }

  // Add a new brand to Firestore
  void addBrand() async {
    if (brandController.text.isNotEmpty) {
      Brand newBrand = Brand(
        brandId:
            DateTime.now().toString(), // or use Firestore auto-generated ID
        teamId: widget.teamId,
        name: brandController.text.trim(),
      );

      // Add the new brand to Firestore
      await _firestoreService.addBrand(newBrand);

      // Refresh the list of brands
      _loadBrands();

      // Clear the input field
      brandController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih atau Tambah Merk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: brandController,
              decoration: InputDecoration(
                labelText: 'Tambah Merk Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addBrand,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: brands.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(brands[index].name),
                          onTap: () {
                            Navigator.pop(context, brands[index].name);
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
