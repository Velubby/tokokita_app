import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String teamId;
  final String userId;
  final String teamName;
  final DateTime createdAt;

  Team({
    required this.teamId,
    required this.userId,
    required this.teamName,
    required this.createdAt,
  });

  factory Team.fromMap(Map<String, dynamic> data, String id) {
    return Team(
      teamId: id,
      userId: data['userId'],
      teamName: data['teamName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'teamName': teamName,
      'createdAt': createdAt,
    };
  }
}
