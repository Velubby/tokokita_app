import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tokokita_app/screens/onboard/team_page.dart';
import 'package:tokokita_app/screens/setting/setting_team_row.dart';

class ManageTeamSection extends StatelessWidget {
  final String teamId;

  const ManageTeamSection({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('teams').doc(teamId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Team data not found'));
          }

          final teamData = snapshot.data?.data() as Map<String, dynamic>;
          final fetchedTeamName = teamData['teamName'] ?? 'No Team';
          final fetchedNotes = teamData['notes'] ?? 'No notes';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Team',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showEditDialog(
                  context,
                  'Team Name',
                  fetchedTeamName,
                  (newValue) {
                    FirebaseFirestore.instance
                        .collection('teams')
                        .doc(teamId)
                        .update({'teamName': newValue});
                  },
                ),
                child: TeamRow(
                  title: 'Team Name',
                  value: fetchedTeamName,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditDialog(
                  context,
                  'Notes',
                  fetchedNotes,
                  (newValue) {
                    FirebaseFirestore.instance
                        .collection('teams')
                        .doc(teamId)
                        .update({'notes': newValue});
                  },
                ),
                child: TeamRow(
                  title: 'Notes',
                  value: fetchedNotes,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamPage(
                        teamId: teamId,
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
                    ),
                  );
                },
                child: TeamRow(
                  title: 'My Teams',
                  value: '',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue,
      Function(String) onSave) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter $title'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
