// lib/services/team_selection_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamSelectionService {
  // Singleton pattern
  static final TeamSelectionService _instance =
      TeamSelectionService._internal();
  factory TeamSelectionService() => _instance;
  TeamSelectionService._internal();

  // SharedPreferences keys
  static const String _selectedTeamIdKey = 'selected_team_id';
  static const String _selectedTeamNameKey = 'selected_team_name';
  static const String _selectedTeamUserIdKey = 'selected_team_user_id';

  // Save selected team
  Future<void> saveSelectedTeam({
    required String teamId,
    required String teamName,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user ID if not provided
    userId ??= FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception('No user authenticated');
    }

    await prefs.setString(_selectedTeamIdKey, teamId);
    await prefs.setString(_selectedTeamNameKey, teamName);
    await prefs.setString(_selectedTeamUserIdKey, userId);
  }

  // Get selected team details
  Future<Map<String, String?>> getSelectedTeam() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'teamId': prefs.getString(_selectedTeamIdKey),
      'teamName': prefs.getString(_selectedTeamNameKey),
      'userId': prefs.getString(_selectedTeamUserIdKey),
    };
  }

  // Get selected team ID
  Future<String?> getSelectedTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedTeamIdKey);
  }

  // Get selected team name
  Future<String?> getSelectedTeamName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedTeamNameKey);
  }

  // Verify if the saved team still exists
  Future<bool> verifyTeamExists() async {
    final teamDetails = await getSelectedTeam();

    if (teamDetails['teamId'] == null || teamDetails['userId'] == null) {
      return false;
    }

    try {
      final teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamDetails['teamId'])
          .get();

      return teamDoc.exists &&
          teamDoc.data()?['userId'] == teamDetails['userId'];
    } catch (e) {
      print('Error verifying team: $e');
      return false;
    }
  }

  // Get the first team for a user if no team is selected
  Future<Map<String, String>?> getFirstTeamForUser(String userId) async {
    try {
      final teamsQuery = await FirebaseFirestore.instance
          .collection('teams')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (teamsQuery.docs.isNotEmpty) {
        final team = teamsQuery.docs.first;
        return {
          'teamId': team.id,
          'teamName': team['teamName'] ?? 'Unnamed Team',
        };
      }
      return null;
    } catch (e) {
      print('Error fetching first team: $e');
      return null;
    }
  }

  // Clear selected team
  Future<void> clearSelectedTeam() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedTeamIdKey);
    await prefs.remove(_selectedTeamNameKey);
    await prefs.remove(_selectedTeamUserIdKey);
  }

  // Helper method to handle team selection with fallback
  Future<Map<String, String>?> ensureTeamSelected() async {
    // Check if a team is already selected and exists
    final isValidTeam = await verifyTeamExists();
    if (isValidTeam) {
      return await getSelectedTeam() as Map<String, String>;
    }

    // If no valid team, try to get the first team for the current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final firstTeam = await getFirstTeamForUser(user.uid);
    if (firstTeam != null) {
      // Save the first team as selected
      await saveSelectedTeam(
          teamId: firstTeam['teamId']!, teamName: firstTeam['teamName']!);
      return firstTeam;
    }

    // No teams found
    return null;
  }
}
