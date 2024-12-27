import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      userId: id,
      name: data['name'],
      email: data['email'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt,
    };
  }
}
