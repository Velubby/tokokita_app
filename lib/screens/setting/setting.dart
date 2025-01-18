import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokokita_app/services/team_selection_service.dart';
import 'package:tokokita_app/screens/onboard/team_page.dart';
import 'package:tokokita_app/screens/setting/setting_partner.dart';
import 'package:tokokita_app/screens/setting/setting_profile.dart';
import 'package:tokokita_app/screens/setting/setting_team.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TeamSelectionService _teamSelectionService = TeamSelectionService();
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _loadSelectedTeam();
  }

  Future<void> _loadSelectedTeam() async {
    final teamDetails = await _teamSelectionService.getSelectedTeam();
    setState(() {
      _selectedTeamId = teamDetails['teamId'];
    });
  }

  void _navigateToTeamSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamPage(
          userId: FirebaseAuth.instance.currentUser!.uid,
          isFromLogin: false,
        ),
      ),
    ).then((_) => _loadSelectedTeam());
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: Text('Please log in to view settings')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('teams')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, teamsSnapshot) {
                if (teamsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (teamsSnapshot.hasError) {
                  return Center(child: Text('Error: ${teamsSnapshot.error}'));
                }

                final teams = teamsSnapshot.data?.docs ?? [];

                if (teams.isEmpty) {
                  return const Center(child: Text('No team found.'));
                }

                return ListView(
                  children: [
                    _buildProfileSection(userData, user, context),
                    const SizedBox(height: 20),
                    _buildManageTeamSection(_selectedTeamId ?? teams.first.id),
                    const SizedBox(height: 20),
                    _buildPartnerSettingsSection(
                        _selectedTeamId ?? teams.first.id),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection(
      Map<String, dynamic> userData, User user, BuildContext context) {
    return ProfileSection(
      userData: userData,
      user: user,
      context: context,
    );
  }

  Widget _buildManageTeamSection(String teamId) {
    return ManageTeamSection(
      teamId: teamId,
    );
  }

  Widget _buildPartnerSettingsSection(String teamId) {
    return PartnerSettingsSection(
      teamId: teamId,
    );
  }
}
