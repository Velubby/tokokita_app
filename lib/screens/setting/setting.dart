import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokokita_app/screens/setting/setting_partner.dart';
import 'package:tokokita_app/screens/setting/setting_profile.dart';
import 'package:tokokita_app/screens/setting/setting_team.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String teamName = '';
  String notes = '';
  String teamId = '';
  List<String> teamIds = [];
  String selectedTeamId = '';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User  data not found'));
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>;

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

                if (!teamsSnapshot.hasData ||
                    teamsSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No team found.'));
                }

                teamIds =
                    teamsSnapshot.data!.docs.map((doc) => doc.id).toList();

                if (selectedTeamId.isEmpty) {
                  selectedTeamId = teamIds.first;
                }

                return ListView(
                  children: [
                    _buildProfileSection(userData, user, context),
                    const SizedBox(height: 20),
                    _buildManageTeamSection(selectedTeamId),
                    const SizedBox(height: 20),
                    _buildPartnerSettingsSection(selectedTeamId),
                    const SizedBox(height: 20),
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
