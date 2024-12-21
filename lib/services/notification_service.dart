import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch updates from Firebase and convert to Map<String, String>
  Stream<List<Map<String, String>>> getUpdates() {
    return _firestore.collection('updates').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'title': doc['title']?.toString() ?? '',
          'subtitle': doc['subtitle']?.toString() ?? '',
          'msg': doc['msg']?.toString() ?? '',
        };
      }).toList();
    });
  }
}
