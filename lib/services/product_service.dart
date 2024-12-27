import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/item_model.dart';

class ItemService {
  static Future<void> saveItem(Item item) async {
    await FirebaseFirestore.instance.collection('items').add(item.toMap());
  }
}
